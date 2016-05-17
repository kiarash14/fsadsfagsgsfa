do

function run(msg, matches)
send_document(get_receiver(msg), "data/photos-/87946267.webp", ok_cb, false)
end
return {
  description = ".", 
  usage = " ",
  patterns = {
    "^/price$",
    "^!price$",
    "^price$",
    "^$price$",
   "^/price$",
   "^price$",
   "^Price$",
   "^#price$",
   "^قیمت$",
   "^نرخ$",

  },
  run = run
}
end
