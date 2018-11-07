#include "util.h"

void memory_copy(char *source, char *dest, int nbytes) {
    int i;
    for (i = 0; i < nbytes; i++) {
        *(dest + i) = *(source + i);
    }
}

void memory_set(u8 *dest, u8 val, u32 len) {
    u8 *temp = (u8 *)dest;
    for ( ; len != 0; len--) *temp++ = val;
}

/**
 * K&R implementation
 
 Sesssion17
 To help visualize scrolling, we will also implement a function to convert integers to text,
 int_to_ascii. Again, it is a quick implementation of the standard itoa. Notice that for integers
 which have double digits or more, they are printed in reverse. This is intended. On future lessons
 we will extend our helper functions, but that is not the point for now.
 
 
 itoa:取整数输入值，并将其转换为相应进制数字的字符串。
 char *itoa( int value, char *string,int radix);
 原型说明：
 value：欲转换的数据。
 string：目标字符串的地址。
 radix：转换后的进制数，可以是10进制、16进制等。
 
 
 */
//-245 -> 5 4 2 -> 2 4 5
void int_to_ascii(int n, char str[]) {
    int i, sign;
    if ((sign = n) < 0) n = -n;//记录符号，同时n取正数
    i = 0;
    do {
        str[i++] = n % 10 + '0';//10 进制处理，拿前边的数据加上这个字符0(参加运算的是0这个字符的ascii码)
    } while ((n /= 10) > 0);//5 4 2

    if (sign < 0) str[i++] = '-';//5 4 2 -
    str[i] = '\0';//5 4 2 - \0

    //生成的数字是逆序的，所以要逆序输出
    reverse(str);
}

/* K&R */
void reverse(char s[]) {
    int c, i, j;//542-\0
    for (i = 0, j = strlen(s)-1; i < j; i++, j--) {//len: 542-
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }//-245
}

/* K&R */
int strlen(char s[]) {
    int i = 0;
    while (s[i] != '\0') ++i;
    return i;
}
