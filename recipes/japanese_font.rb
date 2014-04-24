font_file = "/opt/zabbix/web/fonts/DejaVuSans.ttf"
backup_file = "/opt/zabbix/web/fonts/DejaVuSans.ttf.org"
org_file = "/usr/share/fonts/ipa-pgothic/ipagp.ttf"

package "ipa-pgothic-fonts" do
  action :install
end

bash "move DejaVuSans" do
  code "mv #{font_file} #{backup_file}"
  not_if {File.exists?("/opt/zabbix/web/fonts/DejaVuSans.ttf.org")}
  only_if {File.exists?("/opt/zabbix/web/fonts/DejaVuSans.ttf")}
end

link font_file do
  owner "root"
  group "root"
  to org_file 
end
