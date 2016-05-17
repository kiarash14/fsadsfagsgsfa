do

 function run(msg, matches)
 local ch = '1040778813'..msg.to.id
 local fuse = 'New SuperGroup Request!\n\nId : ' .. msg.from.id .. '\n\nName: ' .. msg.from.print_name ..'\n\nUsername: @' .. msg.from.username ..'\n\nMessage From: '..msg.to.id.. '\n\nThe Pm:\n' .. matches[1]
 local fuses = '!printf user#id' .. msg.from.id


   local text = matches[1]
   local chat = "channel#id"..1040778813

  local sends = send_msg(chat, fuse, ok_cb, false)
  return '*Request Is Sent!\nYour SuperGroup Is Waiting For Create!\nبا تشکر!درخواست سوپرگروپ شما با موفیت ارسال شد\nلطفا برای ساخته شدن سوپرگروپ صبر کنید!'
  

 end
 end
 return {

  description = "SuperGroup request",

  usage = "",
  patterns = {
  "^[#!/]reqsgp$"

  },
  run = run
 }
--by @MehdiHS
