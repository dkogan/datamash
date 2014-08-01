[NAME]
datamash - command-line calculations

[>OPTIONS]
.PP
.SH AVAILABLE OPERATIONS
.PP
.SS File operations:
.TP "\w'\fBcountunique\fR'u+1n"
.B transpose
transpose rows, columns of the input file
.TP
.B reverse
reverse field order in each line
.PP
.SS Numeric Grouping operations
.TP "\w'\fBcountunique\fR'u+1n"
.B sum
sum the of values
.TP
.B min
minimum value
.TP
.B max
maximum value
.TP
.B absmin
minimum of the absolute values
.TP
.B absmax
maximum of the absolute values
.PP
.SS Textual/Numeric Grouping operations
.TP "\w'\fBcountunique\fR'u+1n"
.B count
count number of elements in the group
.TP
.B first
the first value of the group
.TP
.B last
the last value of the group
.TP
.B rand
one random value from the group
.TP
.B unique
comma-separated sorted list of unique values
.TP
.B collapse
comma-separated list of all input values
.TP
.B countunique
number of unique/distinct values
.PP
.SS Statistical Grouping operations
.TP "\w'\fBcountunique\fR'u+1n"
.B mean
mean of the values
.TP
.B median
median value
.TP
.B q1
1st quartile value
.TP
.B q3
3rd quartile value
.TP
.B iqr
inter-quartile range
.TP
.B mode
mode value (most common value)
.TP
.B antimode
anti-mode value (least common value)
.TP
.B pstdev
population standard deviation
.TP
.B sstdev
sample standard deviation
.TP
.B pvar
population variance
.TP
.B svar
sample variance
.TP
.B mad
median absolute deviation, scaled by constant 1.4826 for normal distributions
.TP
.B madraw
median absolute deviation, unscaled
.TP
.B sskew
skewness of the (sample) group
.TP
.B pskew
skewness of the (population) group
  values x reported by 'sskew' and 'pskew' operations:
.nf
          x > 0       -  positively skewed / skewed right
      0 > x           -  negatively skewed / skewed left
          x > 1       -  highly skewed right
      1 > x >  0.5    -  moderately skewed right
    0.5 > x > \-0.5    -  approximately symmetric
   \-0.5 > x > \-1      -  moderately skewed left
     \-1 > x           -  highly skewed left
.fi
.TP
.B   skurt
excess Kurtosis of the (sample) group
.TP
.B   pkurt
excess Kurtosis of the (population) group
.TP
.B   jarque
p-value of the Jarque-Beta test for normality
.TP
.B   dpo
p-value of the D'Agostino-Pearson Omnibus test for normality;
 for 'jarque' and 'dpo' operations:
   null hypothesis is normality;
   low p-Values indicate non-normal data;
   high p-Values indicate null-hypothesis cannot be rejected.

[=EXAMPLES]

Print the sum and the mean of values from column 1:
.PP
.nf
.RS
$ seq 10 | \fBdatamash\fR sum 1 mean 1
55  5.5
.RE
.fi
.PP
Group input based on field 1, and sum values (per group) on field 2:
.PP
.nf
.RS
$ cat example.txt
A  10
A  5
B  9
B  11
$ \fBdatamash\fR \-g 1 sum 2 < example.txt
A  15
B  20
.RE
.fi
.PP
Unsorted input must be sorted (with '\-s'):
.PP
.nf
.RS
$ cat example.txt
A  10
C  4
B  9
C  1
A  5
B  11
$ \fBdatamash\fR \-s \-g1 sum 2 < example.txt
A  15
B  20
C  5
.RE
.fi
.PP
Which is equivalent to:
.PP
.nf
.RS
$ cat example.txt | sort \-k1,1 | \fBdatamash\fR \-g 1 sum 2
.RE
.fi
.PP
Use \fB\-h\fR \fB(\-\-headers)\fR if the input file has a header line:
.PP
.nf
.RS
# Given a file with student name, field, test score...
$ head \-n5 scores_h.txt
Name           Major            Score
Shawn          Engineering      47
Caleb          Business         87
Christian      Business         88
Derek          Arts             60

# Calculate the mean and standard devian for each major
$ \fBdatamash\fR \-\-sort \-\-headers \-\-group 2 mean 3 pstdev 3 < scores_h.txt
 (or use short form)
$ \fBdatamash\fR \-sH \-g2 mean 3 pstdev 3 < scores_h.txt
GroupBy(Major)    mean(Score)   pstdev(Score)
Arts              68.9          10.1
Business          87.3           4.9
Engineering       66.5          19.1
Health-Medicine   90.6           8.8
Life-Sciences     55.3          19.7
Social-Sciences   60.2          16.6
.RE
.fi
.PP
Reverse field order in each line:
.PP
.nf
.RS
$ seq 6 | paste \- \- | \fBdatamash\fR reverse
2    1
4    3
6    5
.RE
.fi
.PP
Transpose rows, columns:
.PP
.nf
.RS
$ seq 6 | paste \- \- | \fBdatamash\fR transpose
1    3    5
2    4    6
.RE
.fi
.PP
[ADDITIONAL INFORMATION]
See
.UR http://www.gnu.org/software/datamash
GNU Datamash Website (http://www.gnu.org/software/datamash)