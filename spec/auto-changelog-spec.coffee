fs = require 'fs-plus'
path = require 'path'
temp = require 'temp'
{WorkspaceView} = require 'atom'

AutoChangelog = require '../lib/auto-changelog'

describe 'AutoChangelog', ->
  describe '.execute', ->
    [directory] = []

    fake = (commandText, out) ->
      out('Test log title')

    beforeEach ->
      directory = temp.mkdirSync()
      atom.project.setPath(directory)

      atom.config.set('auto-changelog.gitPath', '/usr/local/bin/git')

      atom.workspaceView = new WorkspaceView
      atom.workspace = atom.workspaceView.model

      spyOn(AutoChangelog, 'run').andCallFake(fake)

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

        beforeEach ->
          waitsForPromise ->
            atom.workspace.open(filePath).then (e) ->
              editor = e
              buffer = editor.getBuffer()

          waitsForPromise ->
            AutoChangelog.execute()

        it 'does not open a second buffer for the changelog', ->
          filenames = atom.workspace.getEditors().map (e) -> path.basename(e.getPath())
          expect(filenames.length).toBe 1
          expect(filenames).toContain 'CHANGELOG.md'

        it 'adds the top-level header', ->
          expect(buffer.lineForRow(0)).toBe '# CHANGELOG'
          expect(buffer.lineForRow(1)).toBe ''

        it 'adds the master tag header', ->
          expect(buffer.lineForRow(2)).toBe '## **master**'
          expect(buffer.lineForRow(3)).toBe ''

        it 'adds an item for the log entry', ->
          expect(buffer.lineForRow(4)).toBe '* Test log title'

      describe 'when there are already entries', ->
        [buffer] = []

        beforeEach ->
          waitsForPromise ->
            atom.workspace.open(filePath).then (e) ->
              editor = e
              buffer = editor.getBuffer()

          runs ->
            editor.setText """
            # CHANGELOG

            ## **v0.1.0** &mdash; *Released: 23 January 2014*

            * This feature
            * That feature
            * Squashed the other bug
            """

          waitsForPromise ->
            AutoChangelog.execute()

        it 'adds the log entry in the correct location', ->
          expect(buffer.lineForRow(4)).toBe '* Test log title'

        it 'maintains the other contents', ->
          expect(buffer.lineForRow(6)).toBe '## **v0.1.0** &mdash; *Released: 23 January 2014*'
