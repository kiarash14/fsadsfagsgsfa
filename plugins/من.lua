do

local function run(msg, matches)
  if matches[1] == 'من' then
    if is_sudo(msg) then
     --send_document(get_receiver(msg), "/home/Seed/axs/sudo.webp", ok_cb, false)
      return "😍 بابا بیا بغلم 😍"
    elseif is_owner(msg) then
   -- send_document(get_receiver(msg), "/home/Seed/axs/owner.webp", ok_cb, false)
      return "شما صاحب گروه هستی"
    elseif is_momod(msg) then
  --  send_document(get_receiver(msg), "/home/Seed/axs/mod.webp", ok_cb, false)
      return "شما یک کمک مدیر هستی"
    else
  --  send_document(get_receiver(msg), "/root/Tele/axs/mmbr.webp", ok_cb, false)
      return "شما یک عضو معمولی هستید"
    end
  end
end

return {
  patterns = {
    "^(من)$",
    },
  run = run
}
end 
