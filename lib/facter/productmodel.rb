# Fact: productmodel
#
# Purpose:
#   Returns the product model of the system.
#
# Test:
# # facter -p productmodel
# JNP10003-160C [PTX10003-160C]
#
# Caveats:
#

IsContainer = File.exist?('/.dockerenv')

Facter.add(:productmodel) do
  setcode do
    if IsContainer
      require 'net/netconf/jnpr'
      login = { target: 'localhost', username: ENV['NETCONF_USER'] }
      @netconf = Netconf::SSH.new(login)
    else
      require 'net/netconf/jnpr/ioproc'
      @netconf = Netconf::IOProc.new
    end
    ndev.open
    inv_info = ndev.rpc.get_chassis_inventory
    errs = inv_info.xpath('//output')[0]

    if errs && errs.text.include?('This command can only be used on the
                        master routing engine')
      raise Junos::Ez::NoProviderError, 'Puppet can only be used on
                        master routing engine !!'
    end

    chassis = inv_info.xpath('chassis')
    ndev.close
    # Return chassis description which contains productmodel.
    chassis.xpath('description').text
  end
end
