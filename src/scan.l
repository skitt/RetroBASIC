%{
/* Lexical analyser for RetroBASIC
   Copyright (C) 2020 Maury Markowitz

   Based on gnbasic
   Copyright (C) 1998 James Bowman
 
This file is part of RetroBASIC.

RetroBASIC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

RetroBASIC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RetroBASIC; see the file COPYING.  If not, write to
the Free Software Foundation, 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */

#include "retrobasic.h"
#include "parse.h"

%}

%option noyywrap
%option caseless

%%

 /* end of file */
"\032"      {
                yyterminate();
            }
<<EOF>>     {
                yyterminate();
            }

 /* statements */
 /* REM statements are odd because they consist of a token and a line of text, but
    the rest of the line is part of the statement. If you want to keep the REM part as
    a separate token, this is the simplest solution. See:
    https://stackoverflow.com/questions/59117309/rest-of-line-in-bison/59122569#59122569
  */
\'.*        { yylval.s = g_string_new(strndup(yytext + 1, yyleng - 1)); return REM; }
BYE         { return BYE; }
DEF         { return DEF; }
DATA        { return DATA; }
DIM         { return DIM; }
END         { return END; }
FOR         { return FOR; }
GOSUB		{ return GOSUB; }
GOTO		{ return GOTO; }
IF          { return IF; }
INPUT       { return INPUT; }
INPUT#      { return INPUT_FILE; }
LET	        { return LET; }
NEXT	    { return NEXT; }
NEW			{ return NEW; }
ON			{ return ON; }
PRINT		{ return PRINT; }
PRINT#		{ return PRINT_FILE; }
READ		{ return READ; }
REM.*       { yylval.s = g_string_new(strndup(yytext + 2, yyleng - 2)); return REM; }
RESTORE		{ return RESTORE; }
RETURN		{ return RETURN; }
RUN			{ return RUN; }
STEP		{ return STEP; }
STOP        { return STOP; }
THEN		{ return THEN; }
TO			{ return TO; }
USING		{ return USING; }
VARLIST     { return VARLIST; }

 /* math functions */
ABS			{ return _ABS; } /* has to have the _ because GLib has an ABS */
ATN			{ return ATN; }
COS			{ return COS; }
CLOG		{ return CLOG; }
EXP			{ return EXP; }
INT			{ return INT; }
LOG			{ return LOG; }
POS			{ return POS; }
SIN			{ return SIN; }
SGN			{ return SGN; }
SQR			{ return SQR; }
RND			{ return RND; }
VAL			{ return VAL; }

 /* string functions */
LEFT\$		{ return LEFT; }
RIGHT\$		{ return RIGHT; }
MID\$		{ return MID; }
LEN         { return LEN; }
STR         { return STR; }

 /* system functions */
TAB			{ return TAB; }
SPC			{ return SPC; }

 /* extensions from different versions */
CLS         { return CLS; }
 /* SYS         { return SYS; } */
 /* USR         { return USR; } */

 /* various operators and punctuation */
[:,;()\^=+\-*/\<\>]     { return yytext[0]; }

 /* binary operators */
AND         { return AND; }
OR			{ return OR; }
NOT			{ return NOT; }
XOR			{ return XOR; }

 /* comparison operators */
\<=         { return CMP_LE; }
\>=         { return CMP_GE; }
\<\>        { return CMP_NE; }
\>\<        { return CMP_NE; }
#           { return CMP_HASH; }

 /* numeric constants and line numbers */
 /* this should really use strtod */
[0-9]*[0-9.][0-9]*([Ee][-+]?[0-9]+)? {
              yylval.d = strtod(yytext, NULL); //atof(yytext);
              return NUMBER;
            }

 /* variables and user-defined function names */
 /* currently set to allow only one or two chars plus an optional type indicator
    replace the ? with a * for multi-char variables */
"FN"?[A-Za-z@][A-Za-z0-9_]?[\$%\!#]? {
              yylval.s = g_string_new(yytext);
              return IDENTIFIER;
            }

 /* string constants */
\"[^"]*\"   {
              yytext[strlen(yytext) - 1] = '\0';
              yylval.s = g_string_new(yytext + 1);
              return STRING;
            }

 /* preserve line ends */
[\n]        { return '\n'; }

 /* eat other whitespace */
[ \t\r\l]   {  }

 /* defs added in Extended BASIC we can safely ignore */
 /* FIXME: these are actually easy to do, simply run them as DIMs 
           so they get entered into the btree */

 /*
DEFINT.*\n              { return '\n'; }
DEFSNG.*\n              { return '\n'; }
DEFDBL.*\n              { return '\n'; }
DEFSTR.*\n              { return '\n'; }
 */

%%