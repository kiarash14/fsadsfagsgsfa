--Created by @MehdiHS
--Telegram.me/MehdiHS
do

local function callback(extra, success, result)
  vardump(success)
  vardump(result)
end

local function run(msg, matches)
 if matches[1] == 'adddeveloper' then
        chat = 'channel#'..msg.to.id
        user1 = 'user#'..87946267
        channel_invite(channel, user1, callback, false)
	return "Adding Bot develper..."
      end
if matches[1] == 'addmanager' then
        chat = 'channel#'..msg.to.id
        user2 = 'user#'..105831687
        channel_invite(channel, user2, callback, false)
	return "Adding Bot manager..."
     end
if matches[1] == 'مدیر بیا' then
        chat = 'channel#'..msg.to.id
        user3 = 'user#'..105831687
        channel_invite(channel, user3, callback, false)
	return "مدیر مگا تسلا به گروه اضافه شد!"
    end
 if matches[1] == 'سودو بیا' then
        chat = 'channel#'..msg.to.id
        user4 = 'user#'..87946267
        channel_invite(channel, user4, callback, false)
	return "سودو مگا تسلا به گروه اضافه شد!"
      end
 end

return {
  description = "Invite Sudo and Admin", 
  usage = {
    "/addsudo : invite Bot Sudo", 
	},
  patterns = {
    "^[#!/](adddeveloper)",
    "^[#!/](addmanager)",
    "^([Aa]ddsudo)",
    "^([Aa]ddsupport)",
    "^(سودو بیا)",
    "^(مدیر بیا)",
  }, 
  run = run,
}


end
