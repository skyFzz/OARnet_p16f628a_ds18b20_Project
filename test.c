#include <stdlib.h>
#include <stdio.h>
#include <string.h>


int main() {
	unsigned char a[9] = {1, 1, 1, 1, 1, 1, 1, 1, 1};
	memset(a, 0, 9);

	a[0] <<= 1;
	a[0] |= 0b1;
	a[0] <<= 1;
	a[0] |= 0b1;
	a[0] <<= 1;
	a[0] |= 0b1;
	a[0] <<= 1;
	a[0] |= 0b1;
	a[0] <<= 1;
	a[0] |= 0b1;
	a[0] <<= 1;
	a[0] |= 0b1;
	a[0] <<= 1;
	a[0] |= 0b1;
	a[0] <<= 1;
	a[0] |= 0b1;

	printf("%d\n", a[0]);
	
	return 0;

}
