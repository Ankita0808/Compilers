%{
#include <stdio.h>
#include <stdlib.h>
#include "proj2.h"
#include "proj3.h" 
#include "proj4.h"
#include "y.tab.h"

extern int yycolno, yyleng, yylineno;
extern  int yylex();
extern long yylval;
extern  void printHashTbl();
extern  void printStringTbl();
extern  void initHashTbl();
extern  void initStringTbl();
extern void insertString(); /* install string constants & identifiers into string tbl */
%}

/* regular definitions */
delimiters         [ \t]
whitespace         {delimiters}+
newline            [\n]
identifier         [A-Za-z][A-Za-z0-9]*
integerconstant    [0-9]+
erridentifier      [0-9]+{identifier}
stringconstant     '([^'\n\\]*(\\.)?)*'
errstring          '([^'\n\\]*(\\.)?)*[\n]
comment            \/\*
errcomment         \*\/

%%
{whitespace}        {
                      int i;
                      for ( i=0; i<yyleng; i++ )
                      {
                        if ( yytext[i]=='\t' )
                          yycolno = yycolno + 8 - (yycolno&0x7);
                        else
                          yycolno++;
                      }
                    }
{newline}           {yylineno++; yycolno=1;}
"&&"                {yycolno += yyleng; return(ANDnum);}
":="                {yycolno += yyleng; return(ASSGNnum);}
"."                 {yycolno += yyleng; return(DOTnum);}
"="                 {yycolno += yyleng; return(EQUALnum);}
">"                 {yycolno += yyleng; return(GTnum);}
"["                 {yycolno += yyleng; return(LBRACnum);}
"("                 {yycolno += yyleng; return(LPARENnum);}
"!="                {yycolno += yyleng; return(NEnum);}
"||"                {yycolno += yyleng; return(ORnum);}
"]"                 {yycolno += yyleng; return(RBRACnum);}
")"                 {yycolno += yyleng; return(RPARENnum);}
";"                 {yycolno += yyleng; return(SEMInum);}
","                 {yycolno += yyleng; return(COMMAnum);}
"/"                 {yycolno += yyleng; return(DIVIDEnum);}
"=="                {yycolno += yyleng; return(EQnum);}
">="                {yycolno += yyleng; return(GEnum);}
"{"                 {yycolno += yyleng; return(LBRACEnum);}
"<="                {yycolno += yyleng; return(LEnum);}
"<"                 {yycolno += yyleng; return(LTnum);}
"-"                 {yycolno += yyleng; return(MINUSnum);}
"!"                 {yycolno += yyleng; return(NOTnum);}
"+"                 {yycolno += yyleng; return(PLUSnum);}
"}"                 {yycolno += yyleng; return(RBRACEnum);}
"*"                 {yycolno += yyleng; return(TIMESnum);}
"declarations"      {
                     yycolno += yyleng; 
                     return(DECLARATIONSnum);
                    } 
"enddeclarations"   {
                     yycolno+= yyleng;
                     return(ENDDECLARATIONSnum);
                    }
"method"            {yycolno += yyleng; tolowercase(); return(METHODnum);}
"program"           {yycolno += yyleng; tolowercase(); return(PROGRAMnum);}
"val"               {yycolno += yyleng; tolowercase(); return(VALnum);}
"while"             {yycolno += yyleng; tolowercase(); return(WHILEnum);}
"class"             {yycolno += yyleng; tolowercase(); return(CLASSnum);}
"else"              {yycolno += yyleng; tolowercase(); return(ELSEnum);}
"if"                {yycolno += yyleng; tolowercase(); return(IFnum);}
"int"               {yycolno += yyleng; tolowercase(); return(INTnum);}
"return"            {yycolno += yyleng; tolowercase(); return(RETURNnum);}
"void"              {yycolno += yyleng; return(VOIDnum);}
{identifier}        {
                     yycolno += yyleng;
                     tolowercase();
                     insertString(yytext, IDnum);
                     return(IDnum);}
{erridentifier}     {ReportError("Error: Malformed identifier"); yycolno += yyleng;}
{integerconstant}   {yycolno += yyleng; yylval.intg = atoi(yytext); return(ICONSTnum);}
{stringconstant}    {yycolno += yyleng;
                     insertString( yytext, SCONSTnum);
                     return(SCONSTnum);}
{errstring}         {ReportError("Error: Unmatched string constant"); yylineno++; yycolno=1;}
{comment}           { yycolno += yyleng; charMatch(); }
{errcomment}        {yycolno++; ReportError("Error: Unmatched comment");}
.                   {ReportError("Undefined symbol"); while (input() != '\n'); yylineno++; yycolno=1; }
%%

int yycolno = 1;


tolowercase()
{
/* transform an identifier to lower case representation */
  int i;
  for( i=0; i<yyleng; i++ )
  {
     if ( 'A'<=yytext[i] && yytext[i]<='Z' )
        yytext[i] = yytext[i] - 'A' + 'a';
  }
}

ReportError(char* message)
{
  printf("%s '%s', at line %d column %d\n", message, yytext, yylineno, yycolno);
}

charMatch()
{
/* trying to find the ending of the comment, print error message when necessary */
   char c;

   do{
     c = input();
     yycolno++;
     switch ( c ){
     case '*':  c = input();
                if ( c == '/')
                {
                  yycolno++;
                  return;
                }
                break;
     case '\n': yylineno++;
                yycolno=1;
                break;
     case EOF:    ReportError("Unexpected EOF found!!!");
                exit(0);
     default:   break;
     }
	
   } while(1);
}
      
int tokenid;
char* tokens[40]={"EOFnum", "ANDnum", "ASSGNnum", 
                     "DECLARATIONSnum", "DOTnum", "ENDDECLARATIONSnum",
                     "EQUALnum", "GTnum", "IDnum", "INTnum", "LBRACnum",
                     "LPARENnum", "METHODnum", "NEnum", "ORnum", "PROGRAMnum",
                     "RBRACnum", "RPARENnum", "SEMInum", "VALnum", "WHILEnum",
                     "CLASSnum", "COMMAnum", "DIVIDEnum", "ELSEnum", "EQnum",
                     "GEnum", "ICONSTnum", "IFnum", "LBRACEnum", "LEnum", "LTnum",
                     "MINUSnum", "NOTnum", "PLUSnum", "RBRACEnum", "RETURNnum",
                     "SCONSTnum", "TIMESnum", "VOIDnum" };

void mainfunction()
{
  
  printf("Line\tColumn\t%-16s\tIndex_in_String_Table\n", "Token");
  while( 1 )
  {
     switch ( tokenid = yylex() ){
     default:        printf("%d\t%d\t%-16s\n",yylineno,yycolno, tokens[tokenid - 256]); break;
     case SCONSTnum:
     case IDnum:     printf("%d\t%d\t%-16s\t%d\n",yylineno,yycolno, tokens[tokenid - 256], yylval); 
                     break;
     case 0:         printf("%d\t%d\t%-16s\n",yylineno,yycolno, tokens[0]);  /* end of file incurred */
                     /*printf("\nHash Table :\n");
                     printHashTbl();  */
                     printf("\nString Table :\n");
                     printStringTbl();
                     exit(1);
     }
	if(!tokenid )
		{
			printf("%d\t %d\t %-16s\n",yylineno,yycolno, tokens[0]);
			printf("\nString Table :\n");
           		 printStringTbl();
                    		exit(1);
		}
  }
}

int yywrap(void)
{
 return 1;
} 