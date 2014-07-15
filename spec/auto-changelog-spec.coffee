fs = require 'fs-plus'
path = require 'path'
temp = require 'temp'
{WorkspaceView} = require 'atom'

AutoChangelog = require '../lib/auto-changelog'

describe 'AutoChangelog', ->
  describe '.execute', ->
    [directory] = []

    beforeEach ->
      directory = temp.mkdirSync()
      atom.project.setPath(directory)

      atom.workspaceView = new WorkspaceView
      atom.workspace = atom.workspaceView.model

    it 'does nothing if the current project does not contain a CHANGELOG.md', ->
      AutoChangelog.execute()

      expect(fs.readdirSync(directory).length).toBe 0
      expect(atom.workspace.getEditors().length).toBe 0

    describe 'when there is a CHANGELOG.md', ->
      [filePath] = []

      beforeEach ->
        filePath = path.join(directory, 'CHANGELOG.md')
        fs.writeFileSync(filePath, '')

      it 'opens the CHANGELOG if it is not already open', ->
        waitsForPromise ->
          AutoChangelog.execute()

        runs ->
          filenames = atom.workspace.getEditors().map (e) -> path.basename(e.getPath())
          expect(filenames).toContain 'CHANGELOG.md'
