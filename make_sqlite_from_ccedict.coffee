fs = require('fs')
sqlite3 = require('sqlite3').verbose()

dbPath = './dict.sqlite'
edictPath = './cdict.txt'
edictPath = "./#{process.argv[2]}" if process.argv.length > 2

fs.readFile edictPath, 'utf8', (err, data) ->
  return console.log(err)  if err

  lines = data.split('\r\n')
  # ignore commented out lines
  lines = lines.filter (line) -> line[0] isnt '#'

  console.log("Found " + lines.length + " entries.")

  db = new sqlite3.Database(dbPath)
  db.serialize ->
    console.log("Creating TABLE...")
    db.run("DROP TABLE IF EXISTS dict")
    db.run("CREATE TABLE dict (trad TEXT, simp TEXT, pinyin TEXT, entry TEXT)")
    
    console.log("Inserting values...")
    db.run("BEGIN TRANSACTION")
    stmt = db.prepare("INSERT INTO dict VALUES (?, ?, ?, ?)")

    lines.forEach (line) ->
      m = line.match(/(.+)\s+(.+)\s+\[(.+?)\]\s+?\/(.+)\//)
      if m.length isnt 5
        console.log("ERROR REGEXing line: '" + line + "'")
      else
        [trad, simp, pinyin, entry] = m[1..4]
        stmt.run(trad, simp, pinyin, entry)

    console.log("Saving...")
    stmt.finalize()
    db.run("END TRANSACTION")
    db.close()
    console.log("Done.")