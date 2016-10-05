require 'spec_helper'
require 'serverspec'

package = 'npppd'
service = 'npppd'
config  = '/etc/npppd/npppd.conf'
user    = '_npppd'
group   = '_npppd'
ports   = [ 1701 ]

describe file(config) do
  it { should be_file }
  its(:content) { should match /^tunnel l2tp_tunnel protocol l2tp \{\n\s+listen on 10\.0\.2\.15\n\}$/ }
  # tunnel l2tp_tunnel protocol l2tp {
  #   listen on 10.0.2.15
  # }
  # 
  its(:content) { should match /^ipcp ipcp1 \{\n\s+pool-address 192\.168\.100\.1-192\.168\.100\.250\n\s+dns-servers 8\.8\.8\.8\n\}$/ }
  # ipcp ipcp1 {
  #   pool-address 192.168.100.1-192.168.100.250
  #   dns-servers 8.8.8.8
  # }
  # 
  its(:content) { should match /^interface pppx0 address 192\.168\.100\.254 ipcp ipcp1$/ }
  # interface pppx0 address 192.168.100.254 ipcp ipcp1
  # 
  its(:content) { should match /^authentication RADIUS type radius \{\n\s+strip-nt-domain no\n\s+authentication-server {\n\s+address 127\.0\.0\.1 port 1812 secret "password"\n\s+timeout 10\n\s+}\n}/ }
  # authentication RADIUS type radius {
  #   authentication-server {
  #     address 127.0.0.1 port 1812 secret "password"
  #   }
  # }
  its(:content) { should match /^bind tunnel from l2tp_tunnel authenticated by RADIUS to pppx0$/ }
  # bind tunnel from l2tp_tunnel authenticated by RADIUS to pppx0

end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening.with('udp') }
  end
end
