# Auto Changelog

Automatically updates the CHANGELOG of your Atom package based on the `git log` since your last release tag.

## Installation

## Use

1. Creates or appends to the `CHANGELOG.md`, if it exists
1. Inserts or creates header `# CHANGELOG`
1. Inserts or creates header `## **master**`
1. Inserts an entry in the CHANGELOG for each log entry that does not match:
    * `^Merge`
    * `^:memo:`
    * Other configurable patterns

## Configuration



## Copyright

Copyright &copy; [Lee Dohm](http://www.lee-dohm.com) and [Lifted Studios](http://www.liftedstudios.com). See [LICENSE](https://github.com/lee-dohm/auto-changelog/blob/master/LICENSE.md) for details.
