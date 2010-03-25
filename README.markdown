# Improved Intellij IDEA support for buildr

This extension provides better IDEA project file generation support
than that included in buildr itself.

## Improvements

  - VCS: autodetects Subversion or Git and allows manual override
    via `project.ipr.vcs = 'Name'`
  - More modular design allows for easier customization
    - Supports replacing or adding entire component sections
    - Supports changing main & test source lists and the exclude path
      list for module files
  - Expands the default exclude paths to include all target & report 
    directories
  - Adds clean task for removing all generated files
  - Generates module files for all buildr projects, not just ones that are
    packaged, while permitting module file generation to be disabled per
    project using project.no_iml

## Compatibility

It's been tested with IDEA 7.x, IDEA 8.x and IDEA 9.x

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix in a topic branch.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine.  Bump version
  in a commit by itself I can ignore it when I pull)
* Send me a pull request.

## Copyright

Copyright (c) 2010 Rhett Sutphin. See LICENSE and NOTICE for details.
