module RedmineEmailTicketPlugin
  module MailHandlerPatch

    # Override receive_issue to add sender email to custom field
    # and send confirmation email after ticket creation
    def receive_issue
      issue = super
      return issue unless issue.is_a?(Issue)

      sender_email = get_sender_email

      if sender_email.present?
        save_sender_email_to_custom_field(issue, sender_email)
        send_confirmation_email(issue, sender_email)
      end

      issue
    rescue => e
      Rails.logger.error "[RedmineEmailTicketPlugin] Error in receive_issue patch: #{e.message}\n#{e.backtrace.first(5).join(\"\n\") }"
      issue
    end

    private

    def get_sender_email
      @email.from&.first.to_s.strip
    rescue => e
      Rails.logger.error "[RedmineEmailTicketPlugin] Could not get sender email: #{e.message}"
      nil
    end

    def save_sender_email_to_custom_field(issue, sender_email)
      custom_field = IssueCustomField.find_by(name: 'Küldő e-mail címe')

      unless custom_field
        Rails.logger.warn "[RedmineEmailTicketPlugin] Custom field 'Küldő e-mail címe' not found. Please create it in Admin > Custom Fields."
        return
      end

      custom_value = issue.custom_field_values.find { |cfv| cfv.custom_field_id == custom_field.id }

      if custom_value
        custom_value.value = sender_email
        issue.save(validate: false)
        Rails.logger.info "[RedmineEmailTicketPlugin] Saved sender email '#{sender_email}' to custom field for issue ##{issue.id}"
      else
        Rails.logger.warn "[RedmineEmailTicketPlugin] Custom field found but not assigned to project for issue ##{issue.id}"
      end
    rescue => e
      Rails.logger.error "[RedmineEmailTicketPlugin] Error saving sender email to custom field: #{e.message}"
    end

    def send_confirmation_email(issue, sender_email)
      RedmineEmailTicketPlugin::ConfirmationMailer.ticket_received(issue, sender_email).deliver_now
      Rails.logger.info "[RedmineEmailTicketPlugin] Confirmation email sent to '#{sender_email}' for issue ##{issue.id}"
    rescue => e
      Rails.logger.error "[RedmineEmailTicketPlugin] Error sending confirmation email to '#{sender_email}': #{e.message}"
    end

  end
end
