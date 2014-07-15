# Handles the activation and deactivation of the package.
module.exports =
  # Public: Activates the package.
  activate: ->
    atom.workspaceView.command 'auto-changelog:execute', =>
      @execute

  # Public: Updates the CHANGELOG.
  execute: ->
