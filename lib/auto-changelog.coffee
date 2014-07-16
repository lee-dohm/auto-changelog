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
    @openChangelog().then (editor) ->
      return unless editor?
      editor.setText("# CHANGELOG\n\n## **master**\n\n")

  openChangelog: ->
    changelogPath = path.join(atom.project.getPath(), 'CHANGELOG.md')

    if fs.existsSync(changelogPath)
      atom.workspace.open(changelogPath)
    else
      Q()
