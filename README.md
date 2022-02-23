#RedmineX UX Upgrade Plugin
# Foreword
============
Thank you for purchasing the RedmineX UX Upgrade plugin. Below, you will find useful information about the plugin. 


# Contents
============
1. Installation
2. Update
    
## 1. Installation of the UX Upgrade Plugin
============

Follow the standard Redmine plugin installation procedure: <br/>
	<ol type='a'>
		<li>If you are running Redmine using Bitnami, version 4.2.3-27-r02 and above, you will have to make permission adjustments to two of your folders. Go to `/bitnami/redmine/public` and change the `plugin_assets` folder permissions to 777 by running the following command: `chmod -R 777 plugin_assets`. Then go to `/opt/bitnami/redmine/public ` and change the themes folder permissions to 777 by running the following command: `chmod -R 777 themes `. Now you're all set.</li>
		<li>Unzip the archive and copy it to `redmine_root/plugins` or copy the archive in the same location and perform the unzip command in cour console.</li>
		<li>from `redmine_root ` run `bundle install`</li>
		<li>from `redmine_root ` run `bundle exec rake redmine:plugins:migrate RAILS_ENV=production `</li>
		<li>restart Redmine</li>
	</ol>

## 2. Updating The UX Upgrade Plugin
============

These are the steps needed to update the UX Upgrade plugin: <br/>
	<ol type='a'>
		<li>Go to `redmine_root/plugins ` and delete the `000_redmine_x_ux_upgrade` folder</li>
		<li>Go to `redmine_root/public/plugin_assets ` and delete the `000_redmine_x_ux_upgrade` folder</li>
		<li>Restart Redmine</li>
		<li>Copy the new UX Upgrade version into the `redmine_root/plugins ` folder</li>
		<li>from `redmine_root ` run `bundle install`</li>
		<li>from `redmine_root ` run `bundle exec rake redmine:plugins:migrate RAILS_ENV=production `</li>
		<li>Restart Redmine</li>
	</ol>

Enjoy!
RedmineX Team
<br/>
[www.redmine-x.com](https://www.redmine-x.com)