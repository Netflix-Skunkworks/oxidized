class CX < Oxidized::Model

  # Infinera Cloud Xpress model #

  prompt /(^.*[#>] .*$)|(^Login:$)/

  comment '! '

  expect /^\s*-- More --\s+.*$/ do |data, re|
    send ' '
    data.sub re, ''
  end

  cmd :all do |cfg|
    cfg.each_line.to_a[1..-2].join
  end

  cmd :secret do |cfg|
    cfg.gsub! /^(\s+ community).*/, '\\1 <configuration removed>'
    cfg
  end

  cmd 'show inventory' do |cfg|
    comment cfg
  end

  cmd 'show running-config' do |cfg|
    cfg
  end

  cfg :telnet, :ssh do
    # save username and password for second login
    auth = self.node.auth.dup

    # set node auth for first login
    self.node.auth[:username] = 'cliuser'
    self.node.auth[:password] = nil

    if vars :enable
      post_login do
        send auth[:username] + "\n"
        expect /^Enter Password :\s+$/
        send auth[:password] + "\n"
        expect /.*Password ExpireDays.*/
        send "enable\n"
        expect self.node.prompt
      end
    end
    pre_logout 'exit'
  end

end
