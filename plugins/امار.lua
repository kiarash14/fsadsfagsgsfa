do
local function get_msgs_user_chat(user_id, chat_id)
  local user_info = {}
  local uhash = 'user:'..user_id
  local user = redis:hgetall(uhash)
  local um_hash = 'msgs:'..user_id..':'..chat_id
  user_info.msgs = tonumber(redis:get(um_hash) or 0)
  user_info.name = user_print_name(user)..' ['..user_id..']'
  return user_info
end
local function chat_stats(chat_id)
  local hash = 'chat:'..chat_id..':users'
  local users = redis:smembers(hash)
  local users_info = {}
  for i = 1, #users do
    local user_id = users[i]
    local user_info = get_msgs_user_chat(user_id, chat_id)
    table.insert(users_info, user_info)
  end
  table.sort(users_info, function(a, b) 
      if a.msgs and b.msgs then
        return a.msgs > b.msgs
      end
    end)
  local text = 'امار گروه:\n'
  for k,user in pairs(users_info) do
    text = text..user.name..' = '..user.msgs..'\n'
  end
  return text
end

local function get_group_type(target)
  local data = load_data(_config.moderation.data)
  local group_type = data[tostring(target)]['group_type']
    if not group_type or group_type == nil then
       return 'مدل گروه نامشخص'
    end
    return group_type
end

local function get_description(target)
  local data = load_data(_config.moderation.data)
  local data_cat = 'description'
  if not data[tostring(target)][data_cat] then
    return 'درباره ای پیدا نشد'
  end
  local about = data[tostring(target)][data_cat]
  return about
end

local function get_rules(target)
  local data = load_data(_config.moderation.data)
  local data_cat = 'rules'
  if not data[tostring(target)][data_cat] then
    return 'قوانینی وجود ندارد'
  end
  local rules = data[tostring(target)][data_cat]
  return rules
end


local function modlist(target)
  local data = load_data(_config.moderation.data)
  local groups = 'groups'
  if not data[tostring(groups)] or not data[tostring(groups)][tostring(target)] then
    return 'گروه اضافه نشده است یا رلیم است'
  end
  if next(data[tostring(target)]['moderators']) == nil then
    return 'مدیری وجود ندارد'
  end
  local i = 1
  local message = '\nلیست مدیران :\n'
  for k,v in pairs(data[tostring(target)]['moderators']) do
    message = message ..i..' - @'..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

local function get_link(target)
  local data = load_data(_config.moderation.data)
  local group_link = data[tostring(target)]['settings']['set_link']
  if not group_link or group_link == nil then 
    return "لینکی وجود ندارد"
  end
  return "لینک:\n"..group_link
end

local function all(msg,target,receiver)
  local text = "All the things I know about this group\n\n"
  local group_type = get_group_type(target)
  text = text.."مدل گروه: \n"..group_type
  if group_type == "Group" or group_type == "Realm" then
	local settings = show_group_settingsmod(msg,target)
	text = text.."\n\n"..settings
  elseif group_type == "SuperGroup" then
	local settings = show_supergroup_settingsmod(msg,target)
	text = text..'\n\n'..settings
  end
  local rules = get_rules(target)
  text = text.."\n\nقوانین: \n"..rules
  local description = get_description(target)
  text = text.."\n\nدرباره: \n"..description
  local modlist = modlist(target)
  text = text.."\n\nمدیران: \n"..modlist
  local link = get_link(target)
  text = text.."\n\nلینک: \n"..link
  local stats = chat_stats(target)
  text = text.."\n\n"..stats
  local mutes_list = mutes_list(target)
  text = text.."\n\n"..mutes_list
  local muted_user_list = muted_user_list(target)
  text = text.."\n\n"..muted_user_list
  local ban_list = ban_list(target)
  text = text.."\n\n"..ban_list
  local file = io.open("./groups/all/"..target.."all.txt", "w")
  file:write(text)
  file:flush()
  file:close()
  send_document(receiver,"./groups/all/"..target.."all.txt", ok_cb, false)
  return
end

local function run(msg, matches)
  if matches[1] == "امار" and matches[2] and is_owner2(msg.from.id, matches[2]) then
    local receiver = get_receiver(msg)
    local target = matches[2]
    return all(msg,target,receiver)
  end
  if not is_owner(msg) then
    return
  end
  if matches[1] == "امار" and not matches[2] then
    local receiver = get_receiver(msg)
    return all(msg,msg.to.id,receiver)
  end
end


return {
  patterns = {
  "^(امار)$",
  "^(امار) (%d+)$"
  },
  run = run
}
end
