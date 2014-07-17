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
      waitsForPromise ->
        AutoChangelog.execute()

      runs ->
        expect(fs.readdirSync(directory).length).toBe 0
        expect(atom.workspace.getEditors().length).toBe 0

    describe 'when there is a CHANGELOG.md', ->
      [editor, filePath] = []

      beforeEach ->
        filePath = path.join(directory, 'CHANGELOG.md')
        fs.writeFileSync(filePath, '')

      it 'opens the CHANGELOG if it is not already open', ->
        waitsForPromise ->
          AutoChangelog.execute()

        runs ->
          filenames = atom.workspace.getEditors().map (e) -> path.basename(e.getPath())
          expect(filenames.length).toBe 1
          expect(filenames).toContain 'CHANGELOG.md'

      describe 'when the CHANGELOG.md is already open', ->
        [buffer] = []

        fake = (commandText, out) ->
          out('Test log title')

        beforeEach ->
          spyOn(AutoChangelog, 'run').andCallFake(fake)

          waitsForPromise ->
            atom.workspace.open(filePath).then (e) ->
              editor = e
              buffer = editor.getBuffer()

          waitsForPromise ->
            AutoChangelog.execute()

        it 'does not open a second one', ->
          filenames = atom.workspace.getEditors().map (e) -> path.basename(e.getPath())
          expect(filenames.length).toBe 1
          expect(filenames).toContain 'CHANGELOG.md'

        it 'adds the top-level header, if it is not there', ->
          expect(buffer.lineForRow(0)).toBe '# CHANGELOG'
          expect(buffer.lineForRow(1)).toBe ''

        it 'adds the master tag header, if it is not there', ->
          expect(buffer.lineForRow(2)).toBe '## **master**'
          expect(buffer.lineForRow(3)).toBe ''

        it 'adds an item for the log entry', ->
          expect(buffer.lineForRow(4)).toBe '* Test log title'
