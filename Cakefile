{exec} = require 'child_process'
util = require 'util'
Rehab = require 'rehab'

print_output = (process) ->
  process.stderr.on 'data', (data) -> util.print data
  process.stdout.on 'data', (data) -> util.print data

task 'compile-client', 'Build coffee2js using Rehab', ->
  files = new Rehab().process './src/client'

  to_single_file = "--join public/js/app.js"
  from_files = "--compile #{files.join ' '}"

  print_output(exec("coffee #{to_single_file} #{from_files}"))

task 'compile-style', 'Compyles styl files to public folder', ->
  print_output(exec("stylus ./src/style/app.styl --out public/style --include node_modules/nib/lib"))
