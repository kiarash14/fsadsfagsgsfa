antimci= {}-- An empty table for solving multiple kicking problem

do
local function run(msg, matches)
  if is_momod(msg) then -- Ignore mods,owner,admins
    return
  end
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)]['settings']['lock_mci'] then
    if data[tostring(msg.to.id)]['settings']['lock_mci'] == 'yes' then
	  if is_whitelisted(msg.from.id) then
		return
	  end
      if antimci[msg.from.id] == true then 
        return
      end
	  if msg.to.type == 'channel' then
		local receiver = get_receiver(msg)
		local username = msg.from.username
		local name = msg.from.first_name
		if username and is_super_group(msg) then
			send_large_msg(receiver , "User > @"..msg.from.username.." Hamrah Aval Ads Was Not Allowed Here!\n\nیوزر @"..msg.from.username.." تبلیغات همراه اول ممنوع بود!")
		else
			send_large_msg(receiver , "Name > : "..name.."["..msg.from.id.."] Hamrah Aval Ads Was Not Allowed Here!\n\nوضعیت: فرد اخراج شد!")
		end
		local name = user_print_name(msg.from)
		savelog(msg.to.id, name.." ["..msg.from.id.."] kicked (arabic was locked) ")
		local channel_id = msg.to.id
		local user_id = msg.from.id
		        delete_msg(msg.id,ok_cb,false)
			kick_user(user_id, channel_id)
		end
		antimci[msg.from.id] = true
    end
  end
  return
end

local function cron()
  antimci = {} -- Clear antiarabic table 
end

return {
  patterns = {
  "Hamrah Aval(.*)$",
  "hamrah Aval(.*)$",
  "Hamrah aval(.*)$",
  "hamrah aval(.*)$",
  "همراه اول(.*)$",
  "همراه اول  بات(.*)$",
  "بات همراه اول(.*)$",
  "sharzh(.*)$",
  "شارژ همراه اول(.*)$",
    },
  run = run,
  cron = cron
}

end
--
