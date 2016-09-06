require 'spec_helper'

class ServiceNotReady < StandardError
end

sleep 10

context 'after provisioning finished' do

  describe server(:gw1) do
    it 'shows L2TP client' do
      result = current_server.ssh_exec('sudo npppctl session br')
      expect(result).to match /foo\s+L2TP\s+172\.16\.0\.100:1701/
    end
  end

end
