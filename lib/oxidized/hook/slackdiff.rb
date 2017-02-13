require 'slack-notifier'

class SlackDiff < Oxidized::Hook
  def validate_cfg!
    raise KeyError, 'hook.webhook_url is required' unless cfg.has_key?('webhook_url')
    raise KeyError, 'hook.channel is required' unless cfg.has_key?('channel')
    raise KeyError, 'hook.username is required' unless cfg.has_key?('username')
  end

  def run_hook(ctx)
    if ctx.node
      if ctx.event.to_s == "post_store"
        notifier = Slack::Notifier.new cfg.webhook_url, channel: cfg.channel, username: cfg.username
        diff = `cd #{ctx.node.repo.to_s} && git diff --no-color #{ctx.commitref.to_s}~1..#{ctx.commitref.to_s}`
        text = "#{ctx.node.name.to_s} #{ctx.node.group.to_s} #{ctx.node.model.class.name.to_s.downcase}\n```#{diff}```"
        notifier.post text: text
      end
    end
  end
end
