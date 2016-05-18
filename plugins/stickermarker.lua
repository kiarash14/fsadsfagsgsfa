local function run(msg, matches)
        local text = URL.escape(matches[1])
        local color = 'blue'
        if matches[2] == 'قرمز' then
            color = 'red'
        elseif matches[2] == 'سیاه' then
            color = 'black'
      elseif matches[2] == 'ابی' then
          color = 'blue'
    elseif matches[2] == 'سبز' then
        color = 'green'
        elseif matches[2] == 'مشکی' then
        color = 'black'
    elseif matches[2] == 'زرد' then
        color = 'yellow'
    elseif matches[2] == 'صورتی' then
        color = 'magenta'
    elseif matches[2] == 'نارنجی' then
        color = 'Orange'
    elseif matches[2] == 'قهوه ای' then
        color = 'DarkOrange'
        end
        local font = 'mathrm'
        if matches[3] == 'بلد' then
            font = 'mathbf'
        elseif matches[3] == 'کج' then
            font = 'mathit'
        elseif matches[3] == 'شاد' then
            font = 'mathfrak'
        elseif matches[1] == 'اریا' then
            font = 'mathrm'
        end
        local size = '700'
        if matches[4] == 'کوچک' then 
            size = '300'
        elseif matches[4] == 'متوسط' then
            size = '700'
        elseif matches[4] == 'بزرگ' then 
            size = '1200'
            end
local url = 'http://latex.codecogs.com/png.latex?'..'\\dpi{'..size..'}%20\\huge%20\\'..font..'{{\\color{'..color..'}'..text..'}}'
local file = download_to_file(url,'file.webp')
if msg.to.type == 'channel' then
send_document('channel#id'..msg.to.id,file,ok_cb,false)
else
send_document('chat#id'..msg.to.id,file,ok_cb,false)
end
end
return {
   patterns = {
       "^(استیکر) (.*) ([^%s]+) (.*) (کوچک)$",
       "^(استیکر) (.*) ([^%s]+) (.*) (متوسط)$",
       "^(استیکر) (.*) ([^%s]+) (.*) (بزرگ)$",
       "^(استیکر) (.*) ([^%s]+) (بلد)$",
 "^(استیکر) (.*) (بلد)$",
       "^(استیکر) (.*) ([^%s]+) (کج)$",
       "^(استیکر) (.*) ([^%s]+) (شاد)$",
       "^(استیکر) (.*) ([^%s]+) (اریا)$",
       "^(استیکر) (.*) (قرمز)$",
       "^(استیکر) (.*) (سیاه)$",
	   "^(استیکر) (.*) (مشکی)$",
       "^(استیکر) (.*) (ابی)$",
       "^(استیکر) (.*) (سبز)$",
       "^(استیکر) (.*) (زرد)$",
       "^(استیکر) (.*) (صورتی)$",
       "^(استیکر) (.*) (نارنجی)$",
       "^(استیکر) (.*) (قهوه ای)$",
       "^(استیکر) +(.*)$",
       },
   run = run
}
