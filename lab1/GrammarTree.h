enum node_kind  { EXT_DEF_LIST,EXT_VAR_DEF,FUNC_DEF,FUNC_DEC,EXT_DEC_LIST,PARAM_LIST,PARAM_DEC,   \
                  VAR_DEF,DEC_LIST,DEF_LIST,COMP_STM,STM_LIST,EXP_STMT,IF_THEN,IF_THEN_ELSE, FUNC_CALL,ARGS };
struct node {
        //以下对结点属性定义没有考虑存储效率，只是简单地列出要用到的一些属性
	enum node_kind kind;
	union {
		  char type_id[33];             //由标识符生成的叶结点
		  int type_int;                 //由int生成的叶结点
                  char type_char;                //由char类型生成的叶节点
		  float type_float;               //由float类型生成的叶结点   
	      };
    struct node *ptr[3];            //由kind确定有多少棵子树
    int level;                      //层号
    int place;                      //存放表达式入口的位置，这里可以用符号表的位置序号，由此使用一个变量
    char Etrue[15],Efalse[15];      //对布尔表达式的翻译时，真假转移目标的标号
    char Snext[15];                 //语句S执行后的下一条语句位置标号
    struct codenode *code;           //该结点中间代码单链表头指针
    char type[10],op[10];
    int pos;                        //语法单位所在位置行号
    int num;                        //计数器，可以用来统计形参个数
    };

struct node *mknode(int kind,struct node *first,struct node *second, struct node *third,int pos );
