enum node_kind  { EXT_DEF_LIST,EXT_VAR_DEF,FUNC_DEF,FUNC_DEC,EXT_DEC_LIST,PARAM_LIST,PARAM_DEC,   \
                  VAR_DEF,DEC_LIST,DEF_LIST,COMP_STM,STM_LIST,EXP_STMT,IF_THEN,IF_THEN_ELSE, FUNC_CALL,ARGS };
struct node {
        //���¶Խ�����Զ���û�п��Ǵ洢Ч�ʣ�ֻ�Ǽ򵥵��г�Ҫ�õ���һЩ����
	enum node_kind kind;
	union {
		  char type_id[33];             //�ɱ�ʶ�����ɵ�Ҷ���
		  int type_int;                 //��int���ɵ�Ҷ���
                  char type_char;                //��char�������ɵ�Ҷ�ڵ�
		  float type_float;               //��float�������ɵ�Ҷ���   
	      };
    struct node *ptr[3];            //��kindȷ���ж��ٿ�����
    int level;                      //���
    int place;                      //��ű��ʽ��ڵ�λ�ã���������÷��ű��λ����ţ��ɴ�ʹ��һ������
    char Etrue[15],Efalse[15];      //�Բ������ʽ�ķ���ʱ�����ת��Ŀ��ı��
    char Snext[15];                 //���Sִ�к����һ�����λ�ñ��
    struct codenode *code;           //�ý���м���뵥����ͷָ��
    char type[10],op[10];
    int pos;                        //�﷨��λ����λ���к�
    int num;                        //����������������ͳ���βθ���
    };

struct node *mknode(int kind,struct node *first,struct node *second, struct node *third,int pos );
