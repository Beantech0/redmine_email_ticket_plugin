require File.expand_path('../lib/redmine_email_ticket_plugin/mail_handler_patch', __FILE__)
require File.expand_path('../lib/redmine_email_ticket_plugin/issue_patch', __FILE__)

Redmine::Plugin.register :redmine_email_ticket_plugin do
  name 'Redmine Email Ticket Plugin'
  author 'Holyba Attila'
  description 'Küldő e-mail cím mentése egyedi mezőbe és visszaigazoló e-mail küldése ticket létrehozáskor'
  version '1.0.0'
  url 'https://github.com/Beantech0/redmine_email_ticket_plugin'
  author_url 'https://github.com/Beantech0'
end

ActiveSupport.on_load(:after_initialize) do
  unless MailHandler.ancestors.include?(RedmineEmailTicketPlugin::MailHandlerPatch)
    MailHandler.prepend(RedmineEmailTicketPlugin::MailHandlerPatch)
  end

  unless Issue.ancestors.include?(RedmineEmailTicketPlugin::IssuePatch)
    Issue.prepend(RedmineEmailTicketPlugin::IssuePatch)
  end
end