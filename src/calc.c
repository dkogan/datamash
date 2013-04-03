#include <stdio.h>
#include <stdlib.h>

#include "system.h"
#include "config.h"
#include <getopt.h>
#include "linebuffer.h"
#include "error.h"
#include "quote.h"
#include "version.h"
#include "version-etc.h"
#include "xstrtol.h"

/* The official name of this program (e.g., no 'g' prefix).  */
#define PROGRAM_NAME "calc"

#define AUTHORS proper_name ("Assaf Gordon")

/* Until someone better comes along */
const char version_etc_copyright[] = "Copyright %s %d Assaf Gordon" ;

/* enable debugging */
static bool debug = false;

/* The character marking end of line. Default to \n. */
static char eolchar = '\n';

enum
{
  DEBUG_OPTION = CHAR_MAX + 1,
};

static char const short_options[] = "zk:t:";

static struct option const long_options[] =
{
  {"zero-terminated", no_argument, NULL, 'z'},
  {"field-separator", required_argument, NULL, 't'},
  {"debug", no_argument, NULL, DEBUG_OPTION},
  {GETOPT_HELP_OPTION_DECL},
  {GETOPT_VERSION_OPTION_DECL},
  {NULL, 0, NULL, 0},
};

void
usage (int status)
{
  if (status != EXIT_SUCCESS)
    emit_try_help ();
  else
    {
      printf (_("\
Usage: %s [OPTION] op [op ...] col [...]\n\
"),
              program_name);
      fputs (HELP_OPTION_DESCRIPTION, stdout);
      fputs (VERSION_OPTION_DESCRIPTION, stdout);
    }
  exit (status);
}

static bool
valid_op (const char* op)
{
  const char* ops[] =
    {
      "sum", "mean", "median", "max", "min", "count",
      NULL
    };

  const char** p = ops;
  while ( (*p) != NULL )
    {
      if ( STREQ(*p, op) )
        return true;
      p++;
    }
  return false;
}

/* Extract the operation patterns from args START through ARGC - 1 of ARGV. */
static void
parse_operations (int argc, int start, char **argv)
{
  int i = start;	/* Index into ARGV. */
  size_t col;
  const char *op;
  strtol_error e;

  while ( i < argc )
    {
      op = argv[i];
      if (!valid_op(op))
        error (EXIT_FAILURE, 0, _("invalid operation '%s'"), op);
      i++;
      if ( i >= argc )
        error (EXIT_FAILURE, 0, _("missing field number after " \
                                  "operation '%s'"), op );

      e = xstrtoul (argv[i], NULL, 10, &col, NULL);
      /* NOTE: can't use xstrtol_fatal - it's too tightly-coupled
               with getopt command-line processing */
      if (e != LONGINT_OK)
        error (EXIT_FAILURE, 0, _("invalid column '%s'"), argv[i]);
      i++;

      printf ("%s(%zu)\n", op, col);
    }
}

int main(int argc, char* argv[])
{
  int optc;

  set_program_name (argv[0]);

  while ((optc = getopt_long (argc, argv, short_options, long_options, NULL))
         != -1)
    {
      switch (optc)
        {
        case 'z':
          eolchar = 0;
          break;

        case DEBUG_OPTION:
          debug = true;
          break;

        case_GETOPT_HELP_CHAR;

        case_GETOPT_VERSION_CHAR (PROGRAM_NAME, AUTHORS);

        default:
          usage (EXIT_FAILURE);
        }
    }

  if (argc <= optind)
    error (0, 0, _("missing operations specifiers"));

  parse_operations (argc, optind, argv);
}

/* vim: set cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1: */
/* vim: set shiftwidth=2: */
/* vim: set tabstop=8: */
/* vim: set expandtab: */
