%option yylineno

%{
#include<stdio.h>
#include "string.h"
#include "GrammarTree.h"
#include "GrammarTree.tab.h"

int select = 1;
typedef union {
	int type_int;
	float type_float;
	char type_char;
	char type_id[32];
	struct node *ptr;
} YYLVAL;
#define YYSTYPE YYLVAL

%}
%option yylineno

id    [A-Za-z][A-Za-z0-9]*  
int   [0-9]+
float [+-]?([0-9]*\.[0-9]+)|([0-9]+\.)
char  \'[^\'\n']\'

%%
{int}        {
	if(select) printf("(%s, CONSTANTINT)\n", yytext);
	yylval.type_int=atoi(yytext); 
	return INT;
	}
{float}      {
	if(select) printf("(%s, CONSTANTFLOAT)\n", yytext);
	yylval.type_float=atof(yytext); 
	return FLOAT;
	}
{char}       {
	if(select) printf("(%s, CONSTANTCHAR)\n", yytext);
	yylval.type_char=yytext[1];
	return CHAR;
	}
"int"        {
	if(select) printf("(%s, TYPEINT)\n", yytext);
	strcpy(yylval.type_id,  yytext);
	return TYPE;
	}
"float"      {
	if(select) printf("(%s, TYPEFLOAT)\n", yytext);
	strcpy(yylval.type_id,  yytext);
	return TYPE;
	}
"char"       {
	if(select) printf("(%s, TYPECHAR)\n", yytext);
	strcpy(yylval.type_id,  yytext);
	return TYPE;
	}
"return"     {
	if(select) printf("(%s, RETURN)\n", yytext);
	return RETURN;
	}
"if"         {
	if(select) printf("(%s, IF)\n", yytext);
	return IF;
	}
"else"       {
	if(select) printf("(%s, ELSE)\n", yytext);
	return ELSE;
	}
"while"      {
	if(select) printf("(%s, WHILE)\n", yytext);
	return WHILE;
	}
{id}         {
	if(select) printf("(%s, IDENTIFIER)\n", yytext);
	strcpy(yylval.type_id,  yytext); 
	return ID;
	}
";"			{
	if(select) printf("(%s,SEMI)\n",yytext);
	return SEMI;
	}
","			{
	if(select) printf("(%s, COMMA)\n", yytext);
	return COMMA;
	}
">"|"<"|">="|"<="|"=="|"!=" {
	if(select) printf("(%s, RELOP)\n", yytext);
	strcpy(yylval.type_id, yytext);
	return RELOP;
	}
"="			{
	if(select) printf("(%s, ASSIGNOP)\n", yytext);
	return ASSIGNOP;
	}
"+"			{
	if(select) printf("(%s, PLUS)\n", yytext);
	return PLUS;
	}
"-"			{
	if(select) printf("(%s, MINUS)\n", yytext);
	return MINUS;
	}
"*"			{
	if(select) printf("(%s, STAR)\n", yytext);
	return STAR;
	}
"/"			{
	if(select) printf("(%s, DIV)\n", yytext);
	return DIV;
	}
"&&"        {
	if(select) printf("(%s, AND)\n", yytext);
	return AND;
	}
"||"        {
	if(select) printf("(%s, OR)\n", yytext);
	return OR;
	}
"!"			{
	if(select) printf("(%s, NOT)\n", yytext);
	return NOT;
	}
"("			{
	if(select) printf("(%s, LP)\n", yytext); 
	return LP;
	}
")"			{
	if(select) printf("(%s, RP)\n", yytext); 
	return RP;
	}
"{"			{
	if(select) printf("(%s, LC)\n", yytext); 
	return LC;
	}
"}"			{
	if(select) printf("(%s, RC)\n", yytext); 
	return RC;
	}
"++"        {
	if(select) printf("(%s, ADDA)\n", yytext); 
	return ADDA;
	}
"--"        {
	if(select) printf("(%s, SUBS)\n", yytext); 
	return SUBS;
	}
(\/\/.*)|(\/\*((\*[^\/]?)|[^\*]*)*\*\/) {
	if(select) printf("(%s, COMMENT)\n", yytext); 
}
[\n]        {}
[ \r\t]     {}   

.			{printf("Error type A :Mysterious character \"%s\"\n\t at Line %d\n",yytext,yylineno);}

%%

/* 和bison联用时，不需要这部分
void main()
{
yylex();
return 0;
}

*/
int yywrap()
{
return 1;
}
