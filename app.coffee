TelegramBot = require 'node-telegram-bot-api'
fs = require 'fs'

console.log 'Coffee is started! Yay!'
token = fs.readFileSync 'token.txt', 'utf8'
if !token
  console.log 'Please provide token.txt file'
  return
bot = new TelegramBot token, {polling: true}
console.log 'Started'
currentBingos = if fs.existsSync('bingos.json') then JSON.parse fs.readFileSync 'bingos.json', 'utf8' else {}
console.log "current Bingos: #{JSON.stringify(currentBingos)}"

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
  [command, bingoName, bingos...] = msg.text.split ' '
  isSquare = (n) -> (Math.floor Math.sqrt n) == Math.sqrt n
  if !isSquare bingos.length
    bot.sendMessage chatId, "Sorry, cannot create bingo with #{bingos.length} elems. Please provide 4, 9, 16... elems"
    return

  if currentBingos[chatId] and currentBingos[chatId][bingoName]
    bot.sendMessage chatId, 'Sorry, cannot create bingo with existing name. Please provide different name'
    return
  if (!currentBingos[chatId])
    currentBingos[chatId] = {}
  currentBingos[chatId][bingoName] = bingos
  bot.sendMessage chatId, "New Bingo (#{bingoName}) Added!"
  console.log currentBingos

processText = (msg) ->
  chatId = msg.chat.id
  strings = msg.text.split(' ')
  for word in strings
    for key of currentBingos[chatId]
      currentBingos[chatId][key] = currentBingos[chatId][key].filter (key) -> key.toLowerCase() != word.toLowerCase()

  for key of currentBingos[chatId]
    if currentBingos[chatId][key].length == 0
      bot.sendMessage chatId, "Bingo for #{key}!!! You're the lucky one!"
      delete currentBingos[chatId][key]

setInterval (() -> fs.writeFile 'bingos.json', JSON.stringify(currentBingos), 'utf8', () => {}), 1000