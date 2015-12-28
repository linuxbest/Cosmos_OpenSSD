#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <malloc.h>
#include <stdarg.h>
#include <arpa/inet.h>

#include "oschip_api.h"
#include "axi_mm_systemc.h"

typedef uint32_t __le32;

#define fmTraceFuncEnter(I)						\
	fprintf(tfile, "%s %8s:%04d enter %s\n", systemc_time(), __FILE__,  __LINE__, __FUNCTION__); \
	fflush(tfile)
#define fmTraceFuncExit(R,I)  \
	fprintf(tfile, "%s %8s:%04d exit %s(%c)\n",systemc_time(), __FILE__, __LINE__, __FUNCTION__, R); \
	fflush(tfile);
#define fmTrace(U,V) \
	fprintf(tfile, "%s %8s:%04d %s %08x\n", systemc_time(), __FILE__, __LINE__, #V, (uint32_t)V); \
	fflush(tfile);

FILE *tfile;
FILE *sfile;

unsigned char *mem0;
size_t mem_size;

// bit7 - write protect     protect(0), writeable(1)
// bit6 - data cache status busy(0), ready(1)
// bit5 - module status     busy(0), ready(1)
// bit4 - nand  status      busy(0), ready(1)
//
// bit3 - 0
// bit2 - 0
// bit1 - pass (0), fail(1)
// bit0 - pass (0), fail(1)
//
enum {
	DC_STS = 1<<6,
	MT_STS = 1<<5,
	DE_STS = 1<<4,
};

static int check_sts(uint32_t base, int ch)
{
	uint32_t res = osChipRegRead(base + (ch<<4));
	fprintf(tfile, "res %08x: WriteProtect(%s), Data cache(%s), module (%s), nand (%s), %s %s\n",
			res,
			(res & (1<<7)) ? "WR"   : "RO",
			(res & (1<<6)) ? "RDY " : "BUSY",
			(res & (1<<5)) ? "RDY " : "BUSY",
			(res & (1<<4)) ? "RDY " : "BUSY",
			(res & (1<<1)) ? "FAIL" : "PASS",
			(res & (1<<0)) ? "FAIL" : "PASS");
	fflush(tfile);
	if ((res & MT_STS) == MT_STS) {
		if ((res & 0x3) == 0) {
			return 0;
		}
		return 1;
	}
	return res;
}
static int wait_idle(uint32_t base, int ch)
{
	int tmo = 1024;

	do {
		int res = check_sts(base, ch);
		if (res == 0)
			break;
		if (res == 1) {
			fmTrace("todo %d", res);
			break;
		}
		tmo --;
	} while (tmo > 0);

	return tmo == 0;
}

int osChip_init(uint32_t base)
{
	int err = 0, res;
	mem_size = 32*1024*1024;
	mem0 = (unsigned char*)memalign(mem_size, mem_size);
	tfile = fopen("ssd_tb.log", "w+b");

	int i, ch = 7;

	/* wait for ready */
	res = wait_idle(base, ch);
	fmTrace("ready %d.", res);

	/* flash reset */
	osChipRegWrite(base + (ch<<4), 0xff);
	res = wait_idle(base, ch);
	fmTrace("reset flash %d.", res);

	/* change to sync mode */
	osChipRegWrite(base + (ch<<4), 0xef);
	res = wait_idle(base, ch);
	fmTrace("set to sync mode %d.", res);

	/* read */
	osChipRegWrite(base + (ch<<4), 0x01);
	wait_idle(base, ch);
	fmTrace("flash read %d", res);

	return 0;
}

int osChip_interrupt(uint32_t base)
{
	fmTraceFuncEnter("ab");
	fmTraceFuncExit('a', "aa");
	return 0;
}
