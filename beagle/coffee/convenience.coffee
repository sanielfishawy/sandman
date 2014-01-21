# ==========================
# = Javascript Convenience =
# ==========================

# ========================
# = Extensions to String =
# ========================
String.prototype.capitalize_words = () -> this.toLowerCase().replace(/^.|\s\S/g, (a) -> a.toUpperCase());

String.prototype.is_email = () ->
  regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
  return regex.test(this)

String.prototype.is_phone = () -> this.replace(/[^+\d]/g,"").length >= 10
String.prototype.trim_phone = () -> this.replace(/[^+\d]/g,"")
  
String.prototype.initial = () ->  if this.length > 0 then "#{this[0].toUpperCase()}" else ""

String.prototype.briefly = (l) -> if this.length <= l then this.toString() else this[0..l-1] + "&hellip;"

String.prototype.truncate = (l) -> if this.length <= l then this.toString() else this[0..l-1]

String.prototype.escape_html = ->
  chr = {"&": "&amp;", "<": "&lt;", ">": "&gt;", '"': '&quot;', "'": '&#39;', "/": '&#x2F;'}
  String(this).replace(/[&<>"'\/]/g, (s) -> chr[s])

String.prototype.strip_vertical_space = -> String(this).replace(/[\r\n\v\f]+/g, " ")
  
String.prototype.trim = () -> String(this).replace(/^\s+/, "").replace(/\s+$/, "")

String.prototype.is_blank = () -> String(this) is ""

# ========================
# = Extensions to Number =
# ========================
# Angles
Number.prototype.to_rad = -> this*Math.PI/180.0
Number.prototype.to_deg = -> this*180.0/Math.PI
Number.prototype.pos_deg = -> if this < 0 then 360 + (this % 360) else this % 360
# =======================
# = Extensions to Array =
# =======================
Array.prototype.is_blank = () -> this.length is 0

Array.prototype.minus = (b) -> this.filter (a) -> b.indexOf(a) is -1 
Array.prototype.intersect = (b) -> this.filter (a) -> b.indexOf(a) > -1 
  
# Must be an array of numbers
Array.prototype.max = () -> Math.max.apply( Math, this )
Array.prototype.min = () -> Math.min.apply( Math, this )
Array.prototype.sum = () -> 
  sum = 0
  sum += n for n in this
  sum

Array.prototype.mean = () -> this.sum() / this.length
Array.prototype.average = () -> this.mean()

Array.prototype.last = (n=1) -> 
  return null if this.length is 0 and n is 1
  n = if n > this.length then this.length else n
  if n is 1 then this[this.length - 1] else this[(this.length-n)..(this.length - 1)]
  
Array.prototype.first = (n=1) -> 
  return null if this.length is 0 and n is 1
  return this if n < 0
  if n is 1 then this[0] else this[0..n-1]

Array.prototype.longest_word = () -> this.sort((a,b) -> b.length - a.length)[0]
Array.prototype.shortest_word = () -> this.sort((a,b) -> a.length - b.length)[0]

Array.prototype.includes = (el) -> 
  for mem in this
    return true if el is mem
  return false

# Remvoe one or more elements from the array
Array.prototype.remove = (args...) ->
  output = []
  for arg in args
    index = @indexOf arg
    output.push @splice(index, 1) if index isnt -1
  output = output[0] if args.length is 1
  output

Array.prototype.to_sentence = () ->
  if this.length == 0 
    ""
  else if this.length == 1
    this[0].toString()
  else if this.length == 2
    this[0].toString() + " and " + this[1].toString()
  else
    this[0...this.length-1].join(", ") + ", and " + this[this.length-1]

Array.prototype.uniq = () ->
  h = {}
  for el in this
    do ->
      h[el] = true
  return keys(h)