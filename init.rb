require 'redmine'

require_dependency 'redmine_idonethis/listener'

Redmine::Plugin.register :redmine_idonethis do
	name 'Redmine iDoneThis'
	author 'Amin Mirzaee'
	url 'https://github.com/aminland/redmine-idonethis/'
	author_url 'http://www.fluidware.com'
	description 'iDoneThis integration'
	version '0.1'

	requires_redmine :version_or_higher => '0.8.0'

	settings \
		:default => {
			'idonethis_email' => nil,
		},
		:partial => 'settings/idonethis_settings'
end
