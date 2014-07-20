{BufferedProcess} = require 'atom'
fs = require 'fs-plus'
path = require 'path'
Q = require 'q'

# Handles the activation and deactivation of the package.
module.exports =
  # Public: Default configuration values.
  configDefaults:
    gitPath: '/usr/local/bin/git'

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
      @run("#{@gitPath()} --decorate --pretty=\"format:%s\" --no-color --no-merges", out)

  # Internal: Gets the path to the Git executable.
  #
  # Returns the path {String} to the Git executable.
  gitPath: ->
    atom.config.get('auto-changelog.gitPath')

  # Internal: Opens the changelog file.
  #
  # Returns a {Promise} that resolves to the editor for the file.
  openChangelog: ->
    changelogPath = path.join(atom.project.getPath(), 'CHANGELOG.md')

    if fs.existsSync(changelogPath)
      atom.workspace.open(changelogPath)
    else
      Q()

  # Internal: Executes a command for the output.
  #
  # commandText - A {String} containing the command to execute.
  # out - {Function} to call when a line of output is ready.
  #
  # Returns a {Promise} that is resolved when the command is complete.
  run: (commandText, out) ->
    deferred = Q.defer()

    [command, args...] = commandText.split(' ')

    exit = (code) ->
      if code isnt 0
        deferred.reject(new Error("Command '#{commandText}' exited with code #{code}"))
      else
        deferred.resolve()

    options =
      cwd: atom.project.getPath()

    new BufferedProcess({command, args, options, stdout: out, exit})

    deferred.promise
