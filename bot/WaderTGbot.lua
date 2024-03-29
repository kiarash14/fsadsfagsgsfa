package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

require("./bot/utils")

local f = assert(io.popen('/usr/bin/git describe --tags', 'r'))
VERSION = assert(f:read('*a'))
f:close()

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end

  msg = backward_msg_format(msg)

  local receiver = get_receiver(msg)
  print(receiver)
  --vardump(msg)
  --vardump(msg)
  msg = pre_process_service_msg(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    if msg then
      match_plugins(msg)
      if redis:get("bot:markread") then
        if redis:get("bot:markread") == "on" then
          mark_read(receiver, ok_cb, false)
        end
      end
    end
  end
end

function ok_cb(extra, success, result)

end

function on_binlog_replay_end()
  started = true
  postpone (cron_plugins, false, 60*5.0)
  -- See plugins/isup.lua as an example for cron

  _config = load_config()

  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
  -- Don't process outgoing messages
  if msg.out then
    print('\27[36mNot valid: msg from us\27[39m')
    return false
  end

  -- Before bot was started
  if msg.date < os.time() - 5 then
    print('\27[36mNot valid: old msg\27[39m')
    return false
  end

  if msg.unread == 0 then
    print('\27[36mNot valid: readed\27[39m')
    return false
  end

  if not msg.to.id then
    print('\27[36mNot valid: To id not provided\27[39m')
    return false
  end

  if not msg.from.id then
    print('\27[36mNot valid: From id not provided\27[39m')
    return false
  end

  if msg.from.id == our_id then
    print('\27[36mNot valid: Msg from our id\27[39m')
    return false
  end

  if msg.to.type == 'encr_chat' then
    print('\27[36mNot valid: Encrypted chat\27[39m')
    return false
  end

  if msg.from.id == 777000 then
    --send_large_msg(*group id*, msg.text) *login code will be sent to GroupID*
    return false
  end

  return true
end

--
function pre_process_service_msg(msg)
   if msg.service then
      local action = msg.action or {type=""}
      -- Double ! to discriminate of normal actions
      msg.text = "!!tgservice " .. action.type

      -- wipe the data to allow the bot to read service messages
      if msg.out then
         msg.out = false
      end
      if msg.from.id == our_id then
         msg.from.id = 0
      end
   end
   return msg
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end
  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        local warning = 'Plugin '..disabled_plugin..' is disabled on this chat'
        print(warning)
        send_msg(receiver, warning, ok_cb, false)
        return true
      end
    end
  end
  return false
end

function match_plugin(plugin, plugin_name, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches it's enough.
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
        -- If plugin is for privileged users only
        if not warns_user_not_allowed(plugin, msg) then
          local result = plugin.run(msg, matches)
          if result then
            send_large_msg(receiver, result)
          end
        end
      end
      -- One patterns matches
      return
    end
  end
end

-- DEPRECATED, use send_large_msg(destination, text)
function _send_msg(destination, text)
  send_large_msg(destination, text)
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Sudo user: " .. user)
  end
  return config
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
	"admin",
    "onservice",
    "inrealm",
    "ingroup",
    "inpm",
    "banhammer",
    "stats",
    "anti_spam",
    "owners",
    "arabic_lock",
    "set",
    "get",
    "broadcast",
    "invite",
    "all",
    "me",
    "leave_ban",
	"supergroup",
	"whitelist",
	"msg_checks",
	"plugins",
	"badword",
	"bot-lock",
	"clash_of_clan",
	"cleaner",
	"infull",
	"instagram",
	"linkpv",
	"lock-forward",
	"photo2sticker",
	"sticker2photo",
	"text2photo",
	"text2sticker",
	"server",
	"voice",
	"wai"
    },
    sudo_users = {134461890,149921837,209689698,105831687,122997453,123627901},--Sudo users
    moderation = {data = 'data/moderation.json'},
    about_text = [[
]],
    help_text_realm = [[
⚙📃 لیست دستورات ⚙📃
🚷اخراج [یوزرنیم|ایدی] 🚷 اخراج کاربر با ایدی و ریپلی 🚷
😎 تنظیم اسپم [عدد] 😎 عددی از 0 تا 100
🚫🔒فیلتر کردن [کلمه] 🚫🔒 ممنوع کردن یک کلمه در گروه 🚫🔒
🔓✅حذف فیلتر [کلمه] 🔓✅ حذف کلمه فیلتر شده 🔓✅
🔒🚫لیست فیلتر 🔒🚫 کلمات فیلتر شده گروه 🔒🚫
😶 سایلنت [یوزرنیم|ایدی|ریپلی] 😶 ساکت کردن کاربر 😶
😶لیست سکوت 😶 کاربران تحریم شده 😶
✅👤 افزودن مدیر [ایدی یا ریپلی] ✅👤
❌👤 حذف مدیر [ایدی یا ریپلی] ❌👤
📃لیست سفید [ایدی یا ریپلی] 📃 افزودن کاربر مجاز و سفید 📃
📃 لیست سفید 📃 اعضای بدون محدودیت در پیام 📃
👤 لیست مدیران 👤
🔒قفل کردن [اعضا|انگلیسی|چت|اسم بازی|استیکر|گیف|عکس|فیلم|صدا|فایل|مخاطبین|تبلیغات|تگ|سیستم|کانال] 🔒
🔓باز کردن [گروه|اعضا|انگلیسی|چت|متن|استیکر|گیف|عکس|فیلم|صدا|فایل|مخاطبین|تبلیغات|تگ|سیستم|کانال] 🔓
✅ فعال کردن [خوشامد]✅
❌ غیرفعال کردن [خوشامد] ❌
⚙ تنظیم [قوانین|درباره|خوشامد|لینک|نام]⚙
 💭 پاک کردن [قوانین|موضوع|خوشامد|لیست مدیران|لیست سفید|لیست سکوت|لیست فیلتر|لینک] 💭
💭 حذف 💭 حذف پیام گروه با ریپلی 💭
💭 حذف [عدد] 💭 حذف تعدادی از پیام های گروه 💭
📜 قوانین 📜 نمایش قوانین گروه
🔗 لینک 🔗 نمایش لینک فعلی گروه
👥 لیست اعضا 👥 نمایش افراد گروه
🚫 لیست بلاک 🚫 بلاک شدگان از گروه
🤖 بات ها 👈 ربات های درون گروه
🆔 ایدی 🆔 ایدی عددی کاربر با ریپلی 
🆔 ایدی [یوزرنیم|عددی] 🆔 نمایش ایدی یک یوزرنیم
🚪 عمومی [خاموش|روشن] ✅❌
👥 امار 👥 اطلاعات گفتگوی گروه
⚙ تنظیمات ⚙ نمایش تنظیمات گروه
📃 ذخیره [عنوان] <متن> 📃 ذخیره متن با یک عنوان
📬 دریافت [عنوان] 📜 نمایش متن یک عنوان
📂 تاریخچه 📁 نمایش تمام عناوین ذخیره شده
📁 حذف تاریخچه📂 حذف تاریخچه گروه
👥 ایجاد نظرسنجی [متن] 👥 ذخیره یک نظرسنجی
📬 نظرسنجی [عدد] 👥 شرکت در نظرسنجی
🤔نظرسنجی👥 نمایش آمار نظرسنجی
⚙ابزارها 🛠 نمایش لیست ابزارهای ربات
📬 ارسال نظر [متن پیام] 👤 تماس باما
📒 راهنما
]],
    help_text = [[
⚙📃 لیست دستورات ⚙📃
🚷اخراج [یوزرنیم|ایدی] 🚷 اخراج کاربر با ایدی و ریپلی 🚷
😎 تنظیم اسپم [عدد] 😎 عددی از 0 تا 100
🚫🔒فیلتر کردن [کلمه] 🚫🔒 ممنوع کردن یک کلمه در گروه 🚫🔒
🔓✅حذف فیلتر [کلمه] 🔓✅ حذف کلمه فیلتر شده 🔓✅
🔒🚫لیست فیلتر 🔒🚫 کلمات فیلتر شده گروه 🔒🚫
😶 سایلنت [یوزرنیم|ایدی|ریپلی] 😶 ساکت کردن کاربر 😶
😶لیست سکوت 😶 کاربران تحریم شده 😶
✅👤 افزودن مدیر [ایدی یا ریپلی] ✅👤
❌👤 حذف مدیر [ایدی یا ریپلی] ❌👤
📃لیست سفید [ایدی یا ریپلی] 📃 افزودن کاربر مجاز و سفید 📃
📃 لیست سفید 📃 اعضای بدون محدودیت در پیام 📃
👤 لیست مدیران 👤
🔒قفل کردن [اعضا|انگلیسی|چت|اسم بازی|استیکر|گیف|عکس|فیلم|صدا|فایل|مخاطبین|تبلیغات|تگ|سیستم|کانال] 🔒
🔓باز کردن [گروه|اعضا|انگلیسی|چت|متن|استیکر|گیف|عکس|فیلم|صدا|فایل|مخاطبین|تبلیغات|تگ|سیستم|کانال] 🔓
✅ فعال کردن [خوشامد]✅
❌ غیرفعال کردن [خوشامد] ❌
⚙ تنظیم [قوانین|درباره|خوشامد|لینک|نام]⚙
 💭 پاک کردن [قوانین|موضوع|خوشامد|لیست مدیران|لیست سفید|لیست سکوت|لیست فیلتر|لینک] 💭
💭 حذف 💭 حذف پیام گروه با ریپلی 💭
💭 حذف [عدد] 💭 حذف تعدادی از پیام های گروه 💭
📜 قوانین 📜 نمایش قوانین گروه
🔗 لینک 🔗 نمایش لینک فعلی گروه
👥 لیست اعضا 👥 نمایش افراد گروه
🚫 لیست بلاک 🚫 بلاک شدگان از گروه
🤖 بات ها 👈 ربات های درون گروه
🆔 ایدی 🆔 ایدی عددی کاربر با ریپلی 
🆔 ایدی [یوزرنیم|عددی] 🆔 نمایش ایدی یک یوزرنیم
🚪 عمومی [خاموش|روشن] ✅❌
👥 امار 👥 اطلاعات گفتگوی گروه
⚙ تنظیمات ⚙ نمایش تنظیمات گروه
📃 ذخیره [عنوان] <متن> 📃 ذخیره متن با یک عنوان
📬 دریافت [عنوان] 📜 نمایش متن یک عنوان
📂 تاریخچه 📁 نمایش تمام عناوین ذخیره شده
📁 حذف تاریخچه📂 حذف تاریخچه گروه
👥 ایجاد نظرسنجی [متن] 👥 ذخیره یک نظرسنجی
📬 نظرسنجی [عدد] 👥 شرکت در نظرسنجی
🤔نظرسنجی👥 نمایش آمار نظرسنجی
⚙ابزارها 🛠 نمایش لیست ابزارهای ربات
📬 ارسال نظر [متن پیام] 👤 تماس باما
📒 راهنما
]],
	help_text_super =[[
⚙📃 لیست دستورات ⚙📃
🚷اخراج [یوزرنیم|ایدی] 🚷 اخراج کاربر با ایدی و ریپلی 🚷
😎 تنظیم اسپم [عدد] 😎 عددی از 0 تا 100
🚫🔒فیلتر کردن [کلمه] 🚫🔒 ممنوع کردن یک کلمه در گروه 🚫🔒
🔓✅حذف فیلتر [کلمه] 🔓✅ حذف کلمه فیلتر شده 🔓✅
🔒🚫لیست فیلتر 🔒🚫 کلمات فیلتر شده گروه 🔒🚫
😶 سایلنت [یوزرنیم|ایدی|ریپلی] 😶 ساکت کردن کاربر 😶
😶لیست سکوت 😶 کاربران تحریم شده 😶
✅👤 افزودن مدیر [ایدی یا ریپلی] ✅👤
❌👤 حذف مدیر [ایدی یا ریپلی] ❌👤
📃لیست سفید [ایدی یا ریپلی] 📃 افزودن کاربر مجاز و سفید 📃
📃 لیست سفید 📃 اعضای بدون محدودیت در پیام 📃
👤 لیست مدیران 👤
🔒قفل کردن [اعضا|انگلیسی|چت|اسم بازی|استیکر|گیف|عکس|فیلم|صدا|فایل|مخاطبین|تبلیغات|تگ|سیستم|کانال] 🔒
🔓باز کردن [گروه|اعضا|انگلیسی|چت|متن|استیکر|گیف|عکس|فیلم|صدا|فایل|مخاطبین|تبلیغات|تگ|سیستم|کانال] 🔓
✅ فعال کردن [خوشامد]✅
❌ غیرفعال کردن [خوشامد] ❌
⚙ تنظیم [قوانین|درباره|خوشامد|لینک|نام]⚙
 💭 پاک کردن [قوانین|موضوع|خوشامد|لیست مدیران|لیست سفید|لیست سکوت|لیست فیلتر|لینک] 💭
💭 حذف 💭 حذف پیام گروه با ریپلی 💭
💭 حذف [عدد] 💭 حذف تعدادی از پیام های گروه 💭
📜 قوانین 📜 نمایش قوانین گروه
🔗 لینک 🔗 نمایش لینک فعلی گروه
👥 لیست اعضا 👥 نمایش افراد گروه
🚫 لیست بلاک 🚫 بلاک شدگان از گروه
🤖 بات ها 👈 ربات های درون گروه
🆔 ایدی 🆔 ایدی عددی کاربر با ریپلی 
🆔 ایدی [یوزرنیم|عددی] 🆔 نمایش ایدی یک یوزرنیم
🚪 عمومی [خاموش|روشن] ✅❌
👥 امار 👥 اطلاعات گفتگوی گروه
⚙ تنظیمات ⚙ نمایش تنظیمات گروه
📃 ذخیره [عنوان] <متن> 📃 ذخیره متن با یک عنوان
📬 دریافت [عنوان] 📜 نمایش متن یک عنوان
📂 تاریخچه 📁 نمایش تمام عناوین ذخیره شده
📁 حذف تاریخچه📂 حذف تاریخچه گروه
👥 ایجاد نظرسنجی [متن] 👥 ذخیره یک نظرسنجی
📬 نظرسنجی [عدد] 👥 شرکت در نظرسنجی
🤔نظرسنجی👥 نمایش آمار نظرسنجی
⚙ابزارها 🛠 نمایش لیست ابزارهای ربات
📬 ارسال نظر [متن پیام] 👤 تماس باما
📒 راهنما
]],
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
	  print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
      print('\27[31m'..err..'\27[39m')
    end

  end
end

-- custom add
function load_data(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

function save_data(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end


-- Call and postpone execution for cron plugins
function cron_plugins()

  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end

  -- Called again in 2 mins
  postpone (cron_plugins, false, 120)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
started = false
