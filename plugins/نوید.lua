do

local function callback(extra, success, result)
  vardump(success)
  vardump(result)
end

local function run(msg, matches)
  local user = 134461890

  if matches[1] == "نوید" then
    user = 'user#id'..user
  end

  if msg.to.type == 'chat' then
    local chat = 'chat#id'..msg.to.id
    chat_add_user(chat, user, callback, false)
    return "✅ نوید سازنده ربات وارد شد ✅"
elseif msg.to.type == 'channel' then
    local chat = 'channel#id'..msg.to.id
    channel_invite(chat, user, callback, false)
    return "✅ نوید سازنده ربات وارد شد ✅"
  else 
    return '🚫 اینجا یک گروه نمی باشد 🚫'
  end

end

return {
  description = "نوید", 
  patterns = {
    "^(نوید)$"
  }, 
  run = run 
}

end
