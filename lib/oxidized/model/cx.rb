class CX < Oxidized::Model

  # Infinera Cloud Xpress model #

  prompt /(^.+[#>] \e\[0m$)|(^Login:$)/

  comment '// '

  expect /.*-- More --.*/ do |data, re|
    send ' '
    data.sub re, ''
  end

  cmd :all do |cfg|
    cfg.each_line.to_a[1..-2].map { |x| x.sub!(/\e\[2K\r/, "") }.join
  end

  cmd :secret do |cfg|
    cfg.gsub! /(\s*community).*/, '\\1 <configuration removed>'
    cfg
  end

  cmd 'show inventory' do |cfg|
    comment cfg
  end

  cmd 'show running-config' do |cfg|
    cfg
  end

  cfg :telnet, :ssh do
    # store username and password for second login
    auth = self.node.auth.dup

    # set node auth for first login
    self.node.auth[:username] = 'cliuser'
    self.node.auth[:password] = nil

    post_login do
      send auth[:username] + "\n"
      expect /^Enter Password :\s+$/
      send auth[:password] + "\n"
      expect /.*\e\[31m> \e\[0m$/
      send "enable\n"
      expect /^.+# \e\[0m$/
      send "\n"
      expect /^.+# \e\[0m$/

      # restore original auth
      self.node.auth[:username] = auth[:username]
      self.node.auth[:password] = auth[:password]

    end
    pre_logout 'exit'
  end

end
