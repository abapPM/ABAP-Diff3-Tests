REPORT z_differ_test_prog.

* next line was added
MESSAGE 'added line' TYPE 'I'.

* next line was changed
MESSAGE 'changed line' TYPE 'W'.

* next line was removed

* Some comment
" Another comment
DATA variable TYPE string.

variable = 'some text'. " in-line comment
variable = |some text|.
variable = |some { variable } text|.

* eof **
