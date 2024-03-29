
Introduction of Lint
---
* The content introduced in this warehouse involves static code checking and coding style checking
* This mainly introduces coding style checking. Lint is a modified version of cpplint based on Google coding style checking, and it is also named to distinguish it
* The advantages of lint over cpplint are as follows:
  * Lint supports custom coding style checking (through configuration files), not cpplint specific to google style
  * Lint supports generating result files to view and jump through cppcheck host computer

Quick Start
---
```
.
|————doc  (Documentation and process files)
|
|————exe  (Packaged executable program)
|
|————git_hook  (Embed hook file in git)
|
|————.scripts  (Scripts for special usage)
|
|____lint.py  (Cpplint improved version)
```

Application Scenarios
---
>Embed git, check during commit phase<br>

Place the files in the git_hook in the .git/hooks path of your own project to trigger code checks when you commit

![git check in commit](doc/git_commit.png)

>Independent use, based on specific files or folders

Place the script lint_folder.sh and format_cpplint.sh in .scripts at the same level as the directory you want to check

![Directory check](doc/lint_folder.gif)

>Embed jenkins for automated build checking
***

### The results of lint check can be parsed by cppcheck host computer
>Ensure that the checked`xml`result is placed at the previous level of the folder just checked, and then use`cppcheck`to open it to achieve code jumping

![parse lint result](doc/parse_lint.png)

How To Use
---
```txt
./lint.exe --help

Syntax: lint  [--verbose=#] [--output=vs7] [--filter=-x,+y,...]
              [--counting=total|toplevel|detailed] [--root=subdir]
              [--linelength=digits] [--headers=x,y,...]
              [--quiet][--help][--useage][--generate][--about]
        <file> [file] ...

  Option:

    output=vs7
      output is formate: 'emacs', 'vs7', 'eclipse'

    verbose=#
      output level: 0-5, message less than [verbose] will not be printed

    quiet
      Don't print anything if no errors are found

    filter=-x,+y,...
      To see a list of all the categories used in cpplint, pass no arg: --filter=
      Examples: --filter=-whitespace,+whitespace/braces
                --filter=whitespace,runtime/printf,+runtime/printf_format
                --filter=-,+build/include_what_you_use

    counting=total
      Error statistics style. The total number of errors found is always printed
      total    => Total errors found:
      toplevel => Category 'whitespace' errors found:
      detailed => Category 'whitespace/parens' errors found:

    root=subdir
      The root directory used for deriving header guard CPP variable.
      Examples:
        code directory: src/chrome/browser/ui/browser/
        No flag               => CHROME_BROWSER_UI_BROWSER_H_
        --root=chrome         => BROWSER_UI_BROWSER_H_
        --root=chrome/browser => UI_BROWSER_H_
        --root=..             => SRC_CHROME_BROWSER_UI_BROWSER_H_

    linelength=digits
      Code line length, default: 120 characters.

    extensions=extension,extension,...
      The allowed file extensions that cpplint will check
      Examples:
        --extensions=hpp,cpp

    headers=x,y,...
      Examples:
        --headers=hpp,hxx
        --headers=hpp

    help
      Displays short usage information and exits.

    useage
      Displays detaile usage information and exits.

    generate
      Generate lint config file 'LINT.cfg' and exits

    about
      Displays version information and exits.
```

Configuration
---
>Generate custom encoding style configuration file LINT.cfg
```bash
$ ./lint.exe --generate
The LINT.cfg configuration file is generated successfully.
```
>Configuration file description
```python
# Copyright (c) 2022 skull.gu@gmail.com. All rights reserved.

# Stop searching for additional config files.
set noparent

# Specifies the line of code for the project
linelength=120

# Error filter
# -: filter, +: pass
filter=+whitespace/preprocess

# It's not worth lint-gardening the file.
exclude_files=doc

# The root directories are specified relative to CPPLINT.cfg dir
root=

# The header extensions
headers=

# rule.1
# Naming rules for file names
# 0: indifferent, 1: pure lowercase, 2: lowercase +_, 3: lowercase + digit +_, 4: uppercase, 5: uppercase + digit +_
# default: 3
lint_file_naming=

# rule.2
# Whether copyright is required at the beginning of the file
# start of file
# -1: forbidden, 0: indifferent, 1: required
# default: 1
lint_copyright_sof=

# rule.3
# Whether a new line is required at the end of the file
# end of file
# -1: forbidden, 0: indifferent, 1: required
# default: 1
lint_newline_eof=

# rule.4
# Whether to disable TAB
# -1: forbidden, 0: indifferent
# default: -1
lint_use_tab=

# rule.5
# The code line length
# 0: indifferent, >0: length
# default: 120
lint_line_length=

# rule.6
# The number of lines in the function body
# 0: indifferent, >0: length
# default: 80
lint_function_line=

# rule.7
# Number of Spaces to indent code.
# 0: indifferent, >0: length
# default: 4
lint_space_indent=

# rule.8
# Whether extra space at the end of a line is allowed
# -1: forbidden, 0: indifferent
# default: -1
lint_space_eol=

# rule.9
# Whether to allow multiple instructions in a row
# -1: forbidden, 0: indifferent
# default: -1
lint_multiple_cmd=

# rule.10
# Whether blocks of code are required to use curly braces
# -1: forbidden, 0: indifferent, 1: required
# default: 1
lint_block_braces=

# rule.11
# Whether to leave a space before or after the keyword
# -1: forbidden, 0: indifferent, 1: required
# default: 1
lint_space_keyword=

# rule.12
# Whether to require 1 space before and after the operator
# -1: forbidden, 0: indifferent, 1: required
# default: 1
lint_space_operator=

# rule.13
# Whether to ask preprocessor keyword '#include|#define|if|#elif|#ifdef|#ifndef|#endif' thus
# 0: indifferent, 1: required
# default: 1
lint_preprocess_thus=

# rule.14
# For preprocessor keyword '#include|#define|if|#elif|#ifdef|#ifndef|#endif' allow space after '#'
# -1: forbidden, 0: indifferent
# default: -1
lint_preprocess_space=

# rule.15
# Code Style selection
# 1. K&R
# if () {
#     a = b;
# }
# 2. Allman
# if ()
# {
#     a = b;
# }
# 3. Whitesmiths
# if ()
#     {
#     a = b;
#     }
# 4. GNU
# if ()
#     {
#         a = b;
#     }
# default: 1
lint_code_style=

# rule.16
# The function name is lowercase +_
# 0: indifferent, 1: required
# default: 1
lint_func_naming=

# rule.17
# Macro naming rules
# 0: indifferent, 1: uppercase +_, 2: uppercase + number +_
# default: 1
lint_macro_naming=

# rule.18
# Enum naming rules
# 0: indifferent, 1: uppercase +_, 2: uppercase + number +_
# default: 1
lint_enum_naming=

# rule.19
# Whether devil numbers are allowed
# -1: forbidden, 0: indifferent
# default: -1
lint_devil_numbers=

# rule.20
# Comment style selection
# 0: indifferent, 1: //, 2: /**/
# default: 0
lint_comment_style=

# rule.21
# Whether to disallow more than one consecutive blank line
#  0: indifferent, 1: forbidden
# default: 1
lint_blank_line=

# rule.22
# Whether the type conversion using C-style cast (static_cast | const_cast | reinterpret_cast)
#  0: indifferent, 1: required
# default: 0
lint_cstyle_cast=

# rule.23
# Whether to disallow multiple code statements on the same line
# eg: "a = 1; b = 2;", "if (1) { c = 3; }"
#  0: indifferent, 1: forbidden
# default: 1
lint_multiple_code=

# rule.24
# Whether comments are required after '#endif'
#  0: indifferent, 1: required
# default: 0
lint_comment_endif=

```
>The configuration file is stored in the same level directory as Lint, usually in the top-level directory of the project<br>

In Lint, the configuration file will be read, and the option parameters determine the rules to be checked. If the configuration file is not found, Lint uses the default configuration for rule checking


Progress notes
---
1. File name naming rules     ***`[DONE]`***
2. Does the beginning of the file require writing copyright?    ***`[DONE]`***
3. Is a new line required at the end of the file    ***`[DONE]`***
4. Whether to allow the use of TAB    ***`[DONE]`***
5. Code line length requirement    ***`[DONE]`***
6. Number of function lines required    ***`[DONE]`***
7. Number of spaces for code indentation    ***`[DONE]`***
8. Is extra space allowed at the end of a line    ***`[DONE]`***
9. Whether to allow multiple instructions to appear in one line    ***`[DONE]`***
10. Whether to require Code Block (if | else | for | while) to use curly braces  [1]    ***`[DONE]`***
11. Do you require 1 space before and after the keyword    ***`[DONE]`***
12. Whether to leave 1 space before and after the operator (partial implementation)    ***`[TODO]`***
13. Whether to require preprocessing keyword top grid '#include|#>define|if|#elif|#if>def|#ifn>def|#endif'    ***`[DONE]`***
14. Whether to allow spaces after preprocessing keywords hash marks '#include|#>define|if|#elif|#if>def|#ifn>def|#endif'    ***`[DONE]`***
15. Code style selection (implemented'K & R ',' Allman ')   ***`[TODO]`***
16. The function name naming convention is lowercase+_    ***`[DONE]`***
17. Macro naming rules    ***`[DONE]`***
18. Enumeration naming rules  [1]    ***`[DONE]`***
19. Whether devil numbers are allowed to appear    ***`[DONE]`***
20. Annotation style selection    ***`[DONE]`***
21. Whether to prohibit consecutive blank lines exceeding 1 line    ***`[DONE]`***
22. Type conversion uses C-style cast(static_cast|const_cast|reinterpret_cast)    ***`[DONE]`***
23. Whether to prohibit multiple code statements on the same line    ***`[DONE]`***
24. Whether to require comments after '#endif'    ***`[DONE]`***

Note
---
Use the pyinstaller tool to package python files into executable files. Advantage: can run as long as it is in a windows environment<br>
Environment: Python 2.7 cannot be installed directly, a specific version is required `pip2 install pyinstaller==3.2.1`

Work Together
-------
`issue` Welcome to use and feedback