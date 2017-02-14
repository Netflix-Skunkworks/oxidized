require 'slack'

class SlackDiff < Oxidized::Hook
  def validate_cfg!
    raise KeyError, 'hook.token is required' unless cfg.has_key?('token')
    raise KeyError, 'hook.channel is required' unless cfg.has_key?('channel')
  end

  def run_hook(ctx)
    if ctx.node
      if ctx.event.to_s == "post_store"
        client = Slack::Client.new token: cfg.token
        client.auth_test
        diff = `cd #{ctx.node.repo.to_s} && git diff --no-color #{ctx.commitref.to_s}~1..#{ctx.commitref.to_s}`
        title = "#{ctx.node.name.to_s} #{ctx.node.group.to_s} #{ctx.node.model.class.name.to_s.downcase}"
        client.files_upload(channels: cfg.channel, as_user: true,
                             content: diff,
                             filetype: "diff",
                             title: title,
                             filename: "change"
                            )
      end
    end
  end
end
