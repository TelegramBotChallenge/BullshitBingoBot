TelegramBot = require 'node-telegram-bot-api'
fs = require 'fs'

console.log 'Coffee is started! Yay!'
token = fs.readFileSync 'token.txt', 'utf8'
if !token
  console.log 'Please provide token.txt file'
  return
bot = new TelegramBot token, {polling: true}
console.log 'Started'
savedBingos = fs.readFileSync 'bingos.json', 'utf8'
currentBingos = savedBingos && JSON.parse savedBingos || {}
console.log "current Bingos: #{currentBingos}"

bot.on 'message', (msg) ->
  if !msg.text
    return
  text = msg.text
  if text.match /\/create_bingo (\w+) (\w+)( \w+)*/
    processCommand msg
  else if !text.startsWith '/'
    processText msg
  else
    console.log "Unknown command: #{text}"

processCommand = (msg) ->
  chatId = msg.chat.id
  split = msg.text.split ' '
  # isSquare = (n) => Math.floor(Math.sqrt(n)) === Math.sqrt(n)
  # argsLength = split.length - 2
  # if (!isSquare(argsLength)) {
  #     bot.sendMessage(chatId, `Sorry, cannot create bingo with ${argsLength} elems. Please provide 4, 9, 16... elems`)
  #     return
  # }

  bingoName = split[1]
  if currentBingos[bingoName]
    bot.sendMessage chatId, 'Sorry, cannot create bingo with existing name. Please provide different name'
    return
  currentBingos[bingoName] = split.slice 2
  bot.sendMessage chatId, "New Bingo (#{bingoName}) Added!"
  console.log currentBingos

processText = (msg) ->
  chatId = msg.chat.id
  strings = msg.text.split(' ')
  for word in strings
    for key of currentBingos
      currentBingos[key] = currentBingos[key].filter (val) -> val.toLowerCase() != word.toLowerCase()

  for key of currentBingos
      if currentBingos[key].length == 0
        bot.sendMessage chatId, "Bingo for #{key}!!! You're the lucky one!"
        delete currentBingos[key]

setInterval (() -> fs.writeFile 'bingos.json', JSON.stringify(currentBingos), 'utf8', () => {}), 1000