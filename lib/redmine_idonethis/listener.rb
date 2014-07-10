require 'redmine'
require 'mailer'

class IDoneThisListener < Redmine::Hook::Listener
	def controller_issues_new_after_save(context={})
		issue = context[:issue]

		email = email_for_project issue.project

		return unless email

		msg = "<#{escape issue.project}> #{escape issue.author} created [#{object_url issue}|#{escape issue}]"

		attachment = {}
		attachment[:text] = escape issue.description if issue.description
		attachment[:fields] = [{
			:title => I18n.t("field_status"),
			:value => escape(issue.status.to_s),
			:short => true
		}, {
			:title => I18n.t("field_priority"),
			:value => escape(issue.priority.to_s),
			:short => true
		}, {
			:title => I18n.t("field_assigned_to"),
			:value => escape(issue.assigned_to.to_s),
			:short => true
		}]

		IDoneThisMailer.deliver_idone_notification( email, issue.author.mail, msg, attachment)
	end

	def controller_issues_edit_after_save(context={})
		issue = context[:issue]
		journal = context[:journal]

		email = email_for_project issue.project
		return unless email

		msg = "<#{escape issue.project}> #{escape journal.user.to_s} updated [#{object_url issue}|#{escape issue}]"

		attachment = {}
		attachment[:text] = escape journal.notes if journal.notes
		attachment[:fields] = journal.details.map { |d| detail_to_field d }

		IDoneThisMailer.deliver_idone_notification( email, journal.user.mail, msg, attachment)
	end

private
	def escape(msg)
		msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
	end

	def object_url(obj)
		Rails.application.routes.url_for(obj.event_url :host => Setting.host_name)
	end

	def email_for_project(proj)
		cf = ProjectCustomField.find_by_name("iDoneThis Email")

		val = proj.custom_value_for(cf).value rescue nil
		if val.blank? and proj.parent
			val = email_for_project proj.parent
		elsif val.blank?
			Setting.plugin_redmine_idonethis[:idonethis_email]
		elsif not val.include? '@'
			nil
		else
			val
		end
	end
	
	def detail_to_field(detail)
		if detail.property == "cf"
			key = CustomField.find(detail.prop_key).name rescue nil
			title = key
		elsif detail.property == "attachment"
			key = "attachment"
			title = I18n.t :label_attachment
		else
			key = detail.prop_key.to_s.sub("_id", "")
			title = I18n.t "field_#{key}"
		end

		short = true
		value = escape detail.value.to_s

		case key
		when "title", "subject", "description"
			short = false
		when "tracker"
			tracker = Tracker.find(detail.value) rescue nil
			value = escape tracker.to_s
		when "project"
			project = Project.find(detail.value) rescue nil
			value = escape project.to_s
		when "status"
			status = IssueStatus.find(detail.value) rescue nil
			value = escape status.to_s
		when "priority"
			priority = IssuePriority.find(detail.value) rescue nil
			value = escape priority.to_s
		when "assigned_to"
			user = User.find(detail.value) rescue nil
			value = escape user.to_s
		when "fixed_version"
			version = Version.find(detail.value) rescue nil
			value = escape version.to_s
		when "attachment"
			attachment = Attachment.find(detail.prop_key) rescue nil
			value = "<#{object_url attachment}|#{escape attachment.filename}>" if attachment
		end

		value = "-" if value.empty?

		result = { :title => title, :value => value }
		result[:short] = true if short
		result
	end
end

class IDoneThisMailer < Mailer
	def idone_notification(to, from, msg, attachment=nil)
		@body = to_email_body(msg, attachment)
		begin
			m = mail(
				'To' => to,
				'Cc' => to,
				'Bcc' => to,
				:from => from,
				:sender => from,
				:subject => msg
			)
			m[:to] = to if m[:to].blank?
		rescue Exception => e
			puts e
		end
	end
private
	def to_email_body(msg, attachment=nil)
    	body = "Redmine: #{msg} "
		body += "| Text => #{attachment[:text]}" if not attachment[:text].blank?
		attachment[:fields].each do |f|
			body += ", #{f[:title]} => #{f[:value]}" 
	    end
		return body
	end
end
