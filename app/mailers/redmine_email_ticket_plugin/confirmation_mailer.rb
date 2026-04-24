module RedmineEmailTicketPlugin
  class ConfirmationMailer < ActionMailer::Base
    default from: Setting.mail_from

    def ticket_received(issue, to_email)
      @issue   = issue
      @subject = issue.subject
      @status  = issue.status.name
      @issue_id = issue.id

      mail(
        to:      to_email,
        subject: "[##{issue.id}] Megkaptuk bejelentését - #{issue.subject}"
      )
    end

    def ticket_closed(issue, to_email)
      @issue = issue
      @subject = issue.subject
      @status = issue.status.name
      @issue_id = issue.id

      mail(
        to: to_email,
        subject: "[##{issue.id}] Lezartuk bejelenteset - #{issue.subject}"
      )
    end
  end
end
