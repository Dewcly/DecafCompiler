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

//  %type 定义非终结符的语义值类型
%type  <ptr> program ExtDefList ExtDef  Specifier ExtDecList FuncDec CompSt VarList VarDec ParamDec Stmt StmList DefList Def DecList Dec Exp Args

//% token 定义终结符的语义值类型
%token <type_int> INT              /*指定INT的语义值是type_int，有词法分析得到的数值*/
%token <type_id> ID  RELOP TYPE    /*指定ID,RELOP 的语义值是type_id，有词法分析得到的标识符字符串*/
%token <type_float> FLOAT          /*指定ID的语义值是type_id，有词法分析得到的标识符字符串*/
%token <type_char> CHAR
%token LP RP LC RC SEMI COMMA      /*用bison对该文件编译时，带参数-d，生成的exp.tab.h中给这些单词进行编码，可在lex.l中包含parser.tab.h使用这些单词种类码*/
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

program: ExtDefList    {printf("语法树根节点\n"); display($1,0);}     /*显示语法树*/
         ; 
ExtDefList: {$$=NULL;}
          | ExtDef ExtDefList {$$=mknode(EXT_DEF_LIST,$1,$2,NULL,yylineno);}   //每一个EXTDEFLIST的结点，其第1棵子树对应一个外部变量声明或函数
          ;  
ExtDef:   Specifier ExtDecList SEMI   {$$=mknode(EXT_VAR_DEF,$1,$2,NULL,yylineno);}   //该结点对应一个外部变量声明
         |Specifier FuncDec CompSt    {$$=mknode(FUNC_DEF,$1,$2,$3,yylineno);}         //该结点对应一个函数定义
         |error SEMI   {$$=NULL;printf("Error at line %d\n",yylineno);}
         ;
Specifier:  TYPE    {$$=mknode(TYPE,NULL,NULL,NULL,yylineno);strcpy($$->type,$1);}   
           ;      
ExtDecList:  VarDec      {$$=$1;}       /*每一个EXT_DECLIST的结点，其第一棵子树对应一个变量名(ID类型的结点),第二棵子树对应剩下的外部变量名*/
           | VarDec COMMA ExtDecList {$$=mknode(EXT_DEC_LIST,$1,$3,NULL,yylineno);}
           ;  
VarDec:  ID          {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}   //ID结点，标识符符号串存放结点的type_id
         ;
FuncDec: ID LP VarList RP   {$$=mknode(FUNC_DEC,$3,NULL,NULL,yylineno);strcpy($$->type_id,$1);}//函数名存放在$$->type_id
		|ID LP  RP   {$$=mknode(FUNC_DEC,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}//函数名存放在$$->type_id

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
      | CompSt      {$$=$1;}      //复合语句结点直接最为语句结点，不再生成新的结点
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
Exp:    Exp ASSIGNOP Exp {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno);strcpy($$->type_id,"ASSIGNOP");}//$$结点type_id空置未用，正好存放运算符
      | Exp AND Exp   {$$=mknode(AND,$1,$3,NULL,yylineno);strcpy($$->type_id,"AND");}
      | Exp OR Exp    {$$=mknode(OR,$1,$3,NULL,yylineno);strcpy($$->type_id,"OR");}
      | Exp RELOP Exp {$$=mknode(RELOP,$1,$3,NULL,yylineno);strcpy($$->type_id,$2);}  //词法分析关系运算符号自身值保存在$2中
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
   printf("错误：%s   %s  %d\n",s,yytext,yylineno);
   return -1;
 }

/****************************************************************************************************************************
*                                    定义的语言文法                                                                         *
*  program-->ExtDefList                                                                                                     *
*  ExtDefList-->ExtDef ExtDefList | ε        程序是有若干函数定义（简化起见，这里不考虑函数声明的形式），外部变量定义组成   *
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
*  StmList-->Stmt StmList | ε																							     *
*  Stmt->Exp SEMI																											*
*        | CompSt																											*
*        | RETURN Exp SEMI																									*
*        | IF LP Exp RP Stmt																								*
*        | IF LP Exp RP Stmt ELSE stmt																						*
*																															*
*																															*
*																															*
*  DefList-->Def DefList  |    ε																						    *
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

