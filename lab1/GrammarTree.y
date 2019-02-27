%{
#include "stdio.h"
#include "math.h"
#include "string.h"
#include "GrammarTree.h"
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
void display(struct node *,int);
int yylex();
int yyerror();
%}

%union {
	int    type_int;
	float  type_float;
	char   type_id[32];
        char   type_char;
	struct node *ptr;
};

//  %type ������ս��������ֵ����
%type  <ptr> program ExtDefList ExtDef  Specifier ExtDecList FuncDec CompSt VarList VarDec ParamDec Stmt StmList DefList Def DecList Dec Exp Args

//% token �����ս��������ֵ����
%token <type_int> INT              /*ָ��INT������ֵ��type_int���дʷ������õ�����ֵ*/
%token <type_id> ID  RELOP TYPE    /*ָ��ID,RELOP ������ֵ��type_id���дʷ������õ��ı�ʶ���ַ���*/
%token <type_float> FLOAT          /*ָ��ID������ֵ��type_id���дʷ������õ��ı�ʶ���ַ���*/
%token <type_char> CHAR
%token LP RP LC RC SEMI COMMA      /*��bison�Ը��ļ�����ʱ��������-d�����ɵ�exp.tab.h�и���Щ���ʽ��б��룬����lex.l�а���parser.tab.hʹ����Щ����������*/
%token PLUS MINUS ADDA SUBS STAR DIV ASSIGNOP AND OR NOT IF ELSE WHILE RETURN


%left ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right UMINUS NOT
%left ADDA SUBS

%nonassoc LOWER_THEN_ELSE
%nonassoc ELSE

%%

program: ExtDefList    {printf("�﷨�����ڵ�\n"); display($1,0);}     /*��ʾ�﷨��*/
         ; 
ExtDefList: {$$=NULL;}
          | ExtDef ExtDefList {$$=mknode(EXT_DEF_LIST,$1,$2,NULL,yylineno);}   //ÿһ��EXTDEFLIST�Ľ�㣬���1��������Ӧһ���ⲿ������������
          ;  
ExtDef:   Specifier ExtDecList SEMI   {$$=mknode(EXT_VAR_DEF,$1,$2,NULL,yylineno);}   //�ý���Ӧһ���ⲿ��������
         |Specifier FuncDec CompSt    {$$=mknode(FUNC_DEF,$1,$2,$3,yylineno);}         //�ý���Ӧһ����������
         |error SEMI   {$$=NULL;printf("Error at line %d\n",yylineno);}
         ;
Specifier:  TYPE    {$$=mknode(TYPE,NULL,NULL,NULL,yylineno);strcpy($$->type,$1);}   
           ;      
ExtDecList:  VarDec      {$$=$1;}       /*ÿһ��EXT_DECLIST�Ľ�㣬���һ��������Ӧһ��������(ID���͵Ľ��),�ڶ���������Ӧʣ�µ��ⲿ������*/
           | VarDec COMMA ExtDecList {$$=mknode(EXT_DEC_LIST,$1,$3,NULL,yylineno);}
           ;  
VarDec:  ID          {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}   //ID��㣬��ʶ�����Ŵ���Ž���type_id
         ;
FuncDec: ID LP VarList RP   {$$=mknode(FUNC_DEC,$3,NULL,NULL,yylineno);strcpy($$->type_id,$1);}//�����������$$->type_id
		|ID LP  RP   {$$=mknode(FUNC_DEC,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}//�����������$$->type_id

        ;  
VarList: ParamDec  {$$=$1;}
        | ParamDec COMMA  VarList  {$$=mknode(PARAM_LIST,$1,$3,NULL,yylineno);}
        ;
ParamDec: Specifier VarDec         {$$=mknode(PARAM_DEC,$1,$2,NULL,yylineno);}
         ;

CompSt: LC DefList StmList RC    {$$=mknode(COMP_STM,$2,$3,NULL,yylineno);}
       ;
StmList: {$$=NULL; }  
        | Stmt StmList  {$$=mknode(STM_LIST,$1,$2,NULL,yylineno);}
        ;
Stmt:   Exp SEMI    {$$=mknode(EXP_STMT,$1,NULL,NULL,yylineno);}
      | CompSt      {$$=$1;}      //���������ֱ����Ϊ����㣬���������µĽ��
      | RETURN Exp SEMI   {$$=mknode(RETURN,$2,NULL,NULL,yylineno);}
      | IF LP Exp RP Stmt %prec LOWER_THEN_ELSE   {$$=mknode(IF_THEN,$3,$5,NULL,yylineno);}
      | IF LP Exp RP Stmt ELSE Stmt   {$$=mknode(IF_THEN_ELSE,$3,$5,$7,yylineno);}
      | WHILE LP Exp RP Stmt {$$=mknode(WHILE,$3,$5,NULL,yylineno);}
      | error   {$$=NULL;printf("Error at line %d\n",yylineno);}
      ;
  
  
DefList: {$$=NULL; }
        | Def DefList {$$=mknode(DEF_LIST,$1,$2,NULL,yylineno);}
        ;
Def:    Specifier DecList SEMI {$$=mknode(VAR_DEF,$1,$2,NULL,yylineno);}
        ;
DecList: Dec  {$$=$1;}
       | Dec COMMA DecList  {$$=mknode(DEC_LIST,$1,$3,NULL,yylineno);}
	   ;
Dec:     VarDec  {$$=$1;}
       | VarDec ASSIGNOP Exp  {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno);strcpy($$->type_id,"ASSIGNOP");}
       ;
Exp:    Exp ASSIGNOP Exp {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno);strcpy($$->type_id,"ASSIGNOP");}//$$���type_id����δ�ã����ô�������
      | Exp AND Exp   {$$=mknode(AND,$1,$3,NULL,yylineno);strcpy($$->type_id,"AND");}
      | Exp OR Exp    {$$=mknode(OR,$1,$3,NULL,yylineno);strcpy($$->type_id,"OR");}
      | Exp RELOP Exp {$$=mknode(RELOP,$1,$3,NULL,yylineno);strcpy($$->type_id,$2);}  //�ʷ�������ϵ�����������ֵ������$2��
      | Exp PLUS Exp  {$$=mknode(PLUS,$1,$3,NULL,yylineno);strcpy($$->type_id,"PLUS");}
      | Exp MINUS Exp {$$=mknode(MINUS,$1,$3,NULL,yylineno);strcpy($$->type_id,"MINUS");}
      | Exp ADDA      {$$=mknode(ADDA,$1,NULL,NULL,yylineno);strcpy($$->type_id,"ADDA");}
      | Exp SUBS      {$$=mknode(SUBS,$1,NULL,NULL,yylineno);strcpy($$->type_id,"SUBS");}
      | ADDA Exp     {$$=mknode(ADDA,NULL,$2,NULL,yylineno);strcpy($$->type_id,"ADDA");}
      | SUBS Exp     {$$=mknode(SUBS,NULL,$2,NULL,yylineno);strcpy($$->type_id,"SUBS");}
      | Exp STAR Exp  {$$=mknode(STAR,$1,$3,NULL,yylineno);strcpy($$->type_id,"STAR");}
      | Exp DIV Exp   {$$=mknode(DIV,$1,$3,NULL,yylineno);strcpy($$->type_id,"DIV");}
      | LP Exp RP     {$$=$2;}
      | MINUS Exp %prec UMINUS   {$$=mknode(UMINUS,$2,NULL,NULL,yylineno);strcpy($$->type_id,"UMINUS");}
      | NOT Exp       {$$=mknode(NOT,$2,NULL,NULL,yylineno);strcpy($$->type_id,"NOT");}
      | ID LP Args RP {$$=mknode(FUNC_CALL,$3,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
      | ID LP RP      {$$=NULL;}
      | ID            {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
      | INT           {$$=mknode(INT,NULL,NULL,NULL,yylineno);$$->type_int=$1;}
      | FLOAT         {$$=mknode(FLOAT,NULL,NULL,NULL,yylineno);$$->type_float=$1;}
      | CHAR         {$$=mknode(CHAR,NULL,NULL,NULL,yylineno);$$->type_char=$1;}
      |error SEMI   {$$=NULL;printf("Error at line %d\n",yylineno);}
      ;
Args:    Exp COMMA Args    {$$=mknode(ARGS,$1,$3,NULL,yylineno);}
       | Exp               {$$=$1;}
       ;
       
%%

int main(int argc, char *argv[]){
	yyin=fopen(argv[1],"r");
	if (!yyin) return -1;
	yylineno=1;
	yyparse();
	return 0;
	}
	
int yyerror(char *s){
   printf("����%s   %s  %d\n",s,yytext,yylineno);
   return -1;
 }

/****************************************************************************************************************************
*                                    ����������ķ�                                                                         *
*  program-->ExtDefList                                                                                                     *
*  ExtDefList-->ExtDef ExtDefList | ��        �����������ɺ������壨����������ﲻ���Ǻ�����������ʽ�����ⲿ�����������   *
*  ExtDef-->Specifier ExtDecList SEMI                                                                                       *
*          |Specifier FunDec CompSt                                                                                         *
*                                                                                                                           *
*  Specifier-->TYPE																									*
*  ExtDecList-->VarDec | VarDec COMMA ExtDecList																			*
*  VarDec-->ID																												*
*																															*
*  FucDec-->ID LR VarList RP  | ID LR RP																					*
*  VarList-->ParamDec COMMA VarList   |   ParamDec																			*
*  ParamDec-->Specifier VarDec																								*
*																															*
*																															*
*  CompSt-->LC DefList StmList RC																							*
*  StmList-->Stmt StmList | ��																							     *
*  Stmt->Exp SEMI																											*
*        | CompSt																											*
*        | RETURN Exp SEMI																									*
*        | IF LP Exp RP Stmt																								*
*        | IF LP Exp RP Stmt ELSE stmt																						*
*																															*
*																															*
*																															*
*  DefList-->Def DefList  |    ��																						    *
*  Def-->Specifier DecList SEMI																								*		
*  DecList-->Dec  | Dec COMMA DecList																						*
*  Dec-->VarDec  |  VarDec ASSIGNOP Exp																						*
*																															*
*  Exp-->ID ASSIGNOP Exp																									*
*        | Exp AND Exp																										*
*        | Exp OR Exp																										*
*        | Exp RELOP Exp																									*
*        | Exp PLUS Exp																										*
*        | Exp MINUS Exp																									*
*        | Exp STAR Exp																										*
*        | Exp DIV Exp																										*
*        | LP Exp RP																										*
*        | MINUS Exp																										*
*        | NOT Exp																											*
*        | ID LP Args RP																									*
*        | ID LP RP																											*
*																															*
*  Args-->Exp COMMA Args																									*
*        | Exp																												*
*																															*
*****************************************************************************************************************************/

