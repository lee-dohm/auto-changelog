{BufferedProcess} = require 'atom'
fs = require 'fs-plus'
path = require 'path'
Q = require 'q'

# Handles the activation and deactivation of the package.
module.exports =
  # Public: Activates the package.
  activate: ->
    atom.workspaceView.command 'auto-changelog:execute', =>
      @execute

  # Public: Updates the CHANGELOG.
  execute: ->
    @openChangelog().then (editor) =>
      return unless editor?
      editor.setText("# CHANGELOG\n\n## **master**\n\n")
      editor.moveCursorToBottom()

      out = (line) -> editor.insertText("* #{line}")
      @run('/usr/local/bin/git log --decorate --pretty="format:%s" --no-color --no-merges', out)

  # Internal: Opens the changelog file.
  #
  # Returns a {Promise} that resolves to the editor for the file.
  openChangelog: ->
    changelogPath = path.join(atom.project.getPath(), 'CHANGELOG.md')

    if fs.existsSync(changelogPath)
      atom.workspace.open(changelogPath)
    else
      Q()

  # Internal: Executes a command.
  #
  # commandText - A {String} containing the command to execute.
  # out - {Function} to call when a line (or more) of output is ready.
  #
  # Returns a {Promise} that is resolved when the command is complete.
  run: (commandText, out) ->
    deferred = Q.defer()

    parts = commandText.split(' ')
    command = parts[0]
    args = parts.slice(1)
    exit = -> deferred.resolve()
    options =
      cwd: atom.project.getPath()
    new BufferedProcess({command, args, options, stdout: out, exit})

    deferred.promise
