# iDoneThis activity posting plugin for Redmine

This plugin posts updates to your iDoneThis team so you don't have to. 
Some times people do a considerable number of updates to tickets in a given day,
and this plugin will help ensure that your iDoneThis team sees those updates.
Improvements are welcome! Just send a pull request.

A Big thanks goes to @sciyoshi, as this plugin is largely based on his https://github.com/sciyoshi/redmine-slack/ plugin

## Installation

From your Redmine plugins directory, clone this repository as `redmine_idonethis`:

    git clone https://github.com/aminland/redmine-idonethis.git redmine_idonethis

Restart Redmine, and you should see the plugin show up in the Plugins page.
If you would like all slack activity to go to the same team, under the configuration options,
set the iDoneThis Team Email to the email address where you send updates to.

## Customized Routing

You can also route updates to different teams on a per-project basis. To
do this, create a project custom field (Administration > Custom fields > Project)
named `iDoneThis Email`. If no custom team email is defined for a project, the parent
project will be checked (or the default will be used). To prevent all notifications
from being sent for a project, set the custom channel to `-`.

For more information, see http://www.redmine.org/projects/redmine/wiki/Plugins.
