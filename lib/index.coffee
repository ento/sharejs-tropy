fs = require 'fs'
sets = require 'simplesets'
hat = require('hat').rack(26, 10)
sharejs = require 'share'
createDb = require 'share/lib/server/db'
Model = require 'share/lib/server/model'
Mustache = require 'mustache'

template = fs.readFileSync "#{__dirname}/views/page.html.mu", 'utf8'
sharePrefix = "ShareJS:"
docPrefix = sharePrefix + "doc:"

getTitle = (s) ->
  length = 17
  t = s?.replace(/\n+/, "\n").replace(/^\n/, "").split("\n")[0]?.slice(0, length)
  if t and t.length == length
    t += '...'
  t

module.exports = Tropy = (options) ->
  if not this instanceof Tropy
    return new Tropy options

  dbOptions = options?.db
  sharedb = createDb dbOptions
  if sharedb and options?.db == 'redis'
    redis = require 'redis'
    dbcli = redis.createClient dbOptions.port, dbOptions.hostname, dbOptions.redisOptions
  else
    seenDocs = new sets.Set()
  model = new Model sharedb, options

  keyForDoc = (docName) ->
    docPrefix + docName

  docForKey = (key) ->
    key.slice docPrefix.length

  randomDocFromDb = () ->
    keys = dbcli.keys keyForDoc '*'
    pick = keys[Math.floor Math.random() * keys.length]
    docForKey pick

  this.attach = (server) ->
    sharejs.server.attach server, options, model

  this.render = (docName, content, res) ->
    html = Mustache.to_html template, {content, docName, title: getTitle(content), getTitle: getTitle.toString()}
    res.writeHead 200, {'content-type': 'text/html'}
    res.end html

  this.get = (docName, callback) ->
    seenDocs.add?(docName)
    model.getSnapshot docName, (error, data) ->
      if error is 'Document does not exist'
        model.create docName, 'text', ->
          callback docName
      else
        callback docName, data.snapshot

  this.create = (callback) ->
    created = false
    while not created
      docName = hat()
      model.create docName, 'text', (error) ->
        if not error
          created = true
          callback docName

  this.random = (callback) ->
    if dbcli
      callback randomDocFromDb()
    else
      callback seenDocs.pick()

  this
