fs = require('fs')
sqlite3 = require('sqlite3').verbose()

dbPath = './dict.sqlite'
edictPath = './jdict.txt'
edictPath = "./#{process.argv[2]}" if process.argv.length > 2

fs.readFile edictPath, 'utf8', (err, data) ->
  return console.log(err)  if err

  lines = data.split('\n')[1..]

  console.log("Found " + lines.length + " entries.")

  db = new sqlite3.Database(dbPath)
  db.serialize ->
    console.log("Creating TABLE...")
    db.run("DROP TABLE IF EXISTS dict")

    db.run("CREATE TABLE dict (kanji TEXT, kana TEXT, entry TEXT)")
    
    console.log("Inserting values...")
    db.run("BEGIN TRANSACTION")
    stmt = db.prepare("INSERT INTO dict VALUES (?, ?, ?)")

    for line in lines
      fullEntry = /(.+)\s\[(.+)\]\s+?\/(.*)\//
      m = line.match(fullEntry)
      if m?
        [kanji, kana, entry] = m[1..3]
        entry = entry.replace('/',', ')
        stmt.run(kanji, kana, entry)
        continue

      katakanaEntry = /(.+)\s+\/(.+)\//
      m = line.match(katakanaEntry)
      if m?
        [kana, entry] = m[1..2]
        stmt.run(null, kana, entry)
        continue
      else
        console.log("ERROR REGEXing line: '" + line + "'")

    console.log("Saving...")
    stmt.finalize()
    db.run("END TRANSACTION")
    db.close()
    console.log("Done.")