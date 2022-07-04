#!/usr/bin/env perl
=pod
  Unit Tests for GNU Datamash - perform simple calculation on input data

   Copyright (C) 2013-2021 Assaf Gordon <assafgordon@gmail.com>
   Copyright (C) 2022 Dima Kogan <dima@secretsauce.net>

   This file is part of GNU Datamash.

   GNU Datamash is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   GNU Datamash is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with GNU Datamash.  If not, see <https://www.gnu.org/licenses/>.

   Written by Assaf Gordon.
=cut

use strict;
use warnings;

use lib '.';
# Until a better way comes along to auto-use Coreutils Perl modules
# as in the coreutils' autotools system.
use Coreutils;
use CuSkip;
use CuTmpdir qw(datamash);
use MIME::Base64 ;

(my $program_name = $0) =~ s|.*/||;
my $prog_bin = 'datamash';

## Cross-Compiling portability hack:
##  under qemu/binfmt, argv[0] (which is used to report errors) will contain
##  the full path of the binary, if the binary is on the $PATH.
##  So we try to detect what is the actual returned value of the program
##  in case of an error.
my $prog = `$prog_bin ---print-progname`;
$prog = $prog_bin unless $prog;

# TODO: add localization tests with "grouping"
# Turn off localization of executable's output.
@ENV{qw(LANGUAGE LANG LC_ALL)} = ('C') x 3;


# Now the tests. I check vnlog-specific things only

my @Tests = (); # I will append to this list as I add tests
my $in_basic = <<'EOF';
#! comment
##comment
## comment
 ## comment

   
#x y z
   

4 2 3
4 - 6# comment
## comment
- 8 9
EOF

my $in_numeric_columns = <<'EOF';
# 0 1 2
1 2 3
4 - 6
- 8 9
EOF

@Tests =
  ( @Tests,

    ['basic-functionality',
     '-v sum z',
     {IN_PIPE => $in_basic},
     {OUT     => <<'EOF'
# sum(z)
18
EOF
     }],

    ['unique',
     '-v unique x',
     {IN_PIPE => $in_basic},
     {OUT     => <<'EOF'
# unique(x)
-,4
EOF
     }],

    ['need-data-before-legend',
     '-v sum z',
     {IN_PIPE => "5\n" . $in_basic},
     {EXIT    => 1},
     {ERR     => "$prog: invalid vnlog data: received data line prior to the header: '5'\n" }],

    ['option-parsing1',
     '-v -t: sum x',
     {IN_PIPE => $in_basic},
     {EXIT    => 1},
     {ERR     => "$prog: vnlog processing always uses whitespace to separate input fields\n"}
    ],

    ['numeric-columns-no-allowed',
     '-v sum 1',
     {IN_PIPE => $in_basic},
     {EXIT    => 1},
     {ERR     => "$prog: column name '1' not found in input file\n"
     }],

    ['existing-numeric-columns',
     '-v sum 2',
     {IN_PIPE => $in_numeric_columns},
     {OUT     => <<'EOF'
# sum(2)
18
EOF
     }],

    ['groupby',
     '-v -g x sum z',
     {IN_PIPE => $in_basic},
     {OUT     => <<'EOF'
# GroupBy(x) sum(z)
4 9
- 9
EOF
}],

    # empty input = empty output
    [ 'emp1',
      '-v count x',
      {IN_PIPE=>""},
      {ERR=>""}],
    [ 'emp2',
      '-v count x',
      {IN_PIPE=>"# x"},
      {OUT=>"# count(x)\n"}],
  );


my $save_temps = $ENV{SAVE_TEMPS};
my $verbose = $ENV{VERBOSE};

my $fail = run_tests ($program_name, $prog, \@Tests, $save_temps, $verbose);
exit $fail;
