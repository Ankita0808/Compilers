#define TBL_LEN    500        /* Hash table length */
#define STRTBL_LEN 4096      /* String table length */
#define STR_SPRTR  0        /* String seperator in string table */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "proj2.h"
#include "proj3.h" 
#include "proj4.h"
#include "y.tab.h"

extern int yyleng;
extern long yylval;

struct hashelements{
       int token_id;        /* token id: ICONSTnum or IDnum */
       int token_length;       /* token length */
       int str_tbl_index;     /* string table index */
       struct hashelements *next;/*over flow pointer*/
};

struct hashelements *hashtable[TBL_LEN];      /* Hash table of length TBL_LEN */
char     string_table[STRTBL_LEN];   /* String table of length STRTBL_LEN */
int      lastelement = 0;               /* end of the string table, empty */

void initHashTbl()  /* Initialize hash table */
{
   int i;

   for( i=0; i<TBL_LEN; i++ )
   {
     hashtable[i] = NULL;
   }
}

void initStringTbl()
{
   int i;
   for ( i=0; i<STRTBL_LEN; i++ )
      string_table[i] = 0;
}

void printHashTbl()
{
   int i;
   struct hashelements *n;

   printf("TokenID\tTokenLen\tIndex\tNext...\n");
   for( i=0; i<TBL_LEN; i++ )
   {
     n = hashtable[i];
     while ( n != NULL )
     {
       printf("%d\t%d\t%d\t\t", n->token_id, n->token_length, n->str_tbl_index);
       n = n->next;
     }
     printf("\n");
   }
}

void printStringTbl()
{
   int i;

   for( i=0; i<lastelement; i++ )
   {
     if( string_table[i] == -1 )
       printf(" ");
     else
      printf("%c", string_table[i]);
   }
   printf("\n");
}

int computeHashValue( char *s, int l)      /* compute hash value for string in yytext 
                                      taken from book Pg. 436 */
{
   int  i;
   char *t;
   unsigned a=0, b;

   for(i=0, t=s; i<l ; t=t+1, i++)
   {
     a = ( a<<4 ) + (*t);
     if ( b=a&0xf0000000 )
     {
        a = a^(b>>24);
        a = a^b;
     }
   }
   return a%TBL_LEN;
}

void insertString(char* text, int tokenid ) /* insert an id/string into hash table , set yylval */
{
   int ind, i;
   struct hashelements *n, *n0;

   
   yylval.intg = lastelement;  /* starting index in the string table */
   /* search first */
   ind = computeHashValue( text, yyleng );
   n = hashtable[ind];
   n0 = n;
   while ( n != NULL )
   {
       if ( ! strncmp( (char*)&string_table[n->str_tbl_index], text, yyleng )) /* found *//*&& (yyleng == n->token_length)*/
       {
          yylval.intg = n->str_tbl_index;
          return;
       }
       n0 = n;
       n = n->next;
   }

   if( n == NULL )/* did not find */
   {
     /* if the string table is to be overflowed */
     if ( lastelement + yyleng > STRTBL_LEN )
     {
        printf("There is not enough space in string table!!!\n");
        exit(0);
     }

     n = (struct hashelements *)malloc( sizeof(struct hashelements) );
     n->token_id = tokenid;
     n->token_length = yyleng;
     n->str_tbl_index = lastelement;
     n->next = NULL;
     if ( hashtable[ind] == NULL )
        hashtable[ind] = n;
     else
     {
        n0->next = n;
     }
       
     i=0;

   while ( i< yyleng )
     {
       /*if(tokenid==SCONSTnum&&(i==0||i==yyleng-1))
       {
          i++;
      if(i==yyleng-1);      
          continue;
       }*/
       if( text[i] != '\\' )
         string_table[lastelement] = text[i];
       else
       {
         i++;
         switch( text[i] ) {
         case 't':  string_table[lastelement] = '\t'; break;
         case 'n':  string_table[lastelement] = '\n'; break;
         case '\\': string_table[lastelement] = '\\' ; break;
         case '\'': string_table[lastelement] = '\'' ; break;
         default:   string_table[lastelement]='\\'; i--;
         }
       }
       i++;
       lastelement++;
     }

     string_table[lastelement] = STR_SPRTR;
     lastelement++;
   }
}

int loc_str(char* string) /* return string table index if string is stored */
                          /* -1 if not stored */
{
  int i=0; /*start of the string_table*/

  while ( i<lastelement )
    {
      if( strcmp((char*)&string_table[i], string) == 0 ) /* found */
	return i;
      else
	i += strlen((char*)&string_table[i]) + 1; /* forward i to next token */
    }

  if ( i==lastelement )
    return -1;
}

/* hash function */
unsigned hash_func(s)
char *s;
{
    char *p;
    unsigned h = 0, g;

    for(p=s; *p!='\0'; p++) {
        h = (h << 4) + (*p);
        if (g=h&0xf0000000) {
            h = h ^ (g >>24);
            h = h^g;
        }
    }
    return(h % TBL_LEN);
}

/* change the string s to uppercase */
void to_upper(s)
char *s;
{
    char *p;
    int d;

    p=s;  d = 'A'-'a';
    while(*p != '\0') {
        if ((*p >= 'a') && (*p <='z' ))  p += d;
        p++;
    }
}


/* lookup a string in the string buffer
 * if it exists, return its index in the buffer
 * otherwise insert it as an new item in hash table
 */

int hash_lookup(s)
char *s;       /* string to be find */
{
    struct hashelements *p;
    int str_tbl_index, found = 0;

    to_upper(s);
    str_tbl_index=hash_func(s);
    p=hashtable[str_tbl_index];
    while (p!=NULL && !found)
        if (strcmp(string_table+ p->str_tbl_index, s) == 0)
            found = 1;
        else p = p->next;

    if (p==NULL) { /* new item */
        p=(struct hashelements *)malloc(sizeof(struct hashelements));
        p->str_tbl_index=lastelement;
        strcpy(string_table+lastelement,s);
        lastelement += strlen(s)+1;
        p->next=hashtable[str_tbl_index];      /* insert at front */
        hashtable[str_tbl_index]=p;
    }
    return(p->str_tbl_index);
}


     
