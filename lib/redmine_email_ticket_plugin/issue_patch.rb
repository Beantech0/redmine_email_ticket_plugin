module RedmineEmailTicketPlugin
  module IssuePatch
    SENDER_EMAIL_CUSTOM_FIELD_NAME = 'Küldő e-mail címe'.freeze

    def self.prepended(base)
      base.after_commit :send_ticket_closed_email_if_needed, on: :update
    end

    private

    def send_ticket_closed_email_if_needed
      status_change = previous_changes['status_id']
      return unless status_change.is_a?(Array) && status_change.size == 2

      previous_status_id, current_status_id = status_change

      return unless persisted?
      return unless previous_status_id.present?
      return unless current_status_id.present?
      return if previous_status_id == current_status_id

      previous_status = IssueStatus.find_by(id: previous_status_id)
      current_status = IssueStatus.find_by(id: current_status_id)

      return unless current_status&.is_closed?
      return if previous_status&.is_closed?
      return if closure_notification_already_sent_before?

      recipient_email = sender_email_from_custom_field
      return if recipient_email.blank?
      return unless valid_email?(recipient_email)

      RedmineEmailTicketPlugin::ConfirmationMailer.ticket_closed(self, recipient_email).deliver_now
      Rails.logger.info "[RedmineEmailTicketPlugin] Closure email sent to '#{recipient_email}' for issue ##{id}"
    rescue => e
      Rails.logger.error "[RedmineEmailTicketPlugin] Error while sending closure email for issue ##{id}: #{e.message}"
    end

    def sender_email_from_custom_field
      custom_field = IssueCustomField.find_by(name: SENDER_EMAIL_CUSTOM_FIELD_NAME)
      return nil unless custom_field

      custom_value = custom_field_values.detect { |cfv| cfv.custom_field_id == custom_field.id }
      value = custom_value&.value.to_s.strip
      return nil if value.empty?

      value
    rescue => e
      Rails.logger.error "[RedmineEmailTicketPlugin] Error reading sender email custom field for issue ##{id}: #{e.message}"
      nil
    end

    def closure_notification_already_sent_before?
      closed_status_ids = IssueStatus.where(is_closed: true).pluck(:id)
      return false if closed_status_ids.empty?

      latest_journal_id = journals.maximum(:id)
      return false unless latest_journal_id

      journals
        .joins(:details)
        .where('journals.id < ?', latest_journal_id)
        .where(journal_details: { prop_key: 'status_id', value: closed_status_ids.map(&:to_s) })
        .exists?
    end

    def valid_email?(email)
      email.match?(/\A[^@\s]+@[^@\s]+\z/)
    end
  end
end