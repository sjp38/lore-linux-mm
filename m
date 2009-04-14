Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2BB6E5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 00:35:57 -0400 (EDT)
Date: Tue, 14 Apr 2009 12:36:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
Message-ID: <20090414043611.GA4385@localhost>
References: <20090414042231.GA4341@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ReaqsoxgOBHFXBhH"
Content-Disposition: inline
In-Reply-To: <20090414042231.GA4341@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 14, 2009 at 12:22:31PM +0800, Wu Fengguang wrote:
> Export the following page flags in /proc/kpageflags,
> just in case they will be useful to someone:
> 
> - PG_swapcache
> - PG_swapbacked
> - PG_mappedtodisk
> - PG_reserved
> - PG_private
> - PG_private_2
> - PG_owner_priv_1
> 
> - PG_head
> - PG_tail
> - PG_compound
> 
> - PG_unevictable
> - PG_mlocked
> 
> - PG_poison
> 
> Also add the following two pseudo page flags:
> 
> - PG_MMAP:   whether the page is memory mapped
> - PG_NOPAGE: whether the page is present
> 
> This increases the total number of exported page flags to 25.

And here are two simple tools utilizing the exported page flags:

# ./page-types         
   flags        page-count       MB  symbolic-flags             long-symbolic-flags
0x000000            472521     1845  _________________________
0x000020                 1        0  _____l___________________  lru
0x000028              2516        9  ___U_l___________________  uptodate,lru
0x00002c              5209       20  __RU_l___________________  referenced,uptodate,lru
0x000068               234        0  ___U_lA__________________  uptodate,lru,active
0x00006c               981        3  __RU_lA__________________  referenced,uptodate,lru,active
0x000228                49        0  ___U_l___x_______________  uptodate,lru,reclaim
0x000400               547        2  __________B______________  buddy
0x000804                 1        0  __R________m_____________  referenced,mmap
0x000828              1073        4  ___U_l_____m_____________  uptodate,lru,mmap
0x00082c               318        1  __RU_l_____m_____________  referenced,uptodate,lru,mmap
0x000868               235        0  ___U_lA____m_____________  uptodate,lru,active,mmap
0x00086c               822        3  __RU_lA____m_____________  referenced,uptodate,lru,active,mmap
0x000880              1510        5  _______S___m_____________  slab,mmap
0x0008c0                49        0  ______AS___m_____________  active,slab,mmap
0x002078                 1        0  ___UDlA______b___________  uptodate,dirty,lru,active,swapbacked
0x00207c                17        0  __RUDlA______b___________  referenced,uptodate,dirty,lru,active,swapbacked
0x002808                10        0  ___U_______m_b___________  uptodate,mmap,swapbacked
0x002868              3296       12  ___U_lA____m_b___________  uptodate,lru,active,mmap,swapbacked
0x00286c                25        0  __RU_lA____m_b___________  referenced,uptodate,lru,active,mmap,swapbacked
0x002878                 2        0  ___UDlA____m_b___________  uptodate,dirty,lru,active,mmap,swapbacked
0x008000             19247       75  _______________r_________  reserved
0x080000                15        0  ___________________H_____  head
0x080014                 1        0  __R_D______________H_____  referenced,dirty,head
0x080880               915        3  _______S___m_______H_____  slab,mmap,head
0x0808c0                60        0  ______AS___m_______H_____  active,slab,mmap,head
0x100000              4309       16  ____________________T____  tail
0x100014                 4        0  __R_D_______________T____  referenced,dirty,tail
   total            513968     2007

To show the compound tail pages:
# ./page-areas 0x100000
    offset      len         KB
      3089        3       12KB
    487441        7       28KB
    487449        7       28KB
    487457        7       28KB
    487465        7       28KB
    487473        7       28KB
    487481        7       28KB
    487489        7       28KB
    487497        7       28KB
    487505        7       28KB
    487513        7       28KB
    487521        7       28KB
    487529        7       28KB
    487537        7       28KB
    487545        7       28KB
    487553        7       28KB
    487561        7       28KB
    487569        7       28KB
    487577        7       28KB
    487585        7       28KB
    487593        7       28KB
    487617        7       28KB
    487627        1        4KB
    487629        1        4KB
    487633        7       28KB
    487641        7       28KB
    487649        7       28KB
    487657        7       28KB
    487665        7       28KB
    487673        7       28KB
    487681        7       28KB
    487689        7       28KB
    487697        7       28KB
    487705        7       28KB
    487713        7       28KB
    487721        7       28KB
    487729        7       28KB
    487737        7       28KB
    487745        7       28KB
    487753        7       28KB
    487761        7       28KB
    487769        7       28KB
    487777        7       28KB
    487785        7       28KB
    487793        7       28KB
    487801        7       28KB
    487809        7       28KB
    487817        7       28KB
    487825        7       28KB
    487853        3       12KB
    487865        7       28KB
    487873        3       12KB
    487893        3       12KB
    487897        3       12KB
    487901        3       12KB
    487905        3       12KB
    487909        3       12KB
    487929        7       28KB
    487937        7       28KB
    487945        7       28KB
    493569        3       12KB
    493573        1        4KB
    493575        1        4KB
    493585        7       28KB
    493593        3       12KB
    493597        3       12KB
    493601        7       28KB
    493609        7       28KB
    493617        7       28KB
    493625        1        4KB
    493633        7       28KB
    493641        3       12KB
    493645        3       12KB
[snip]

Thanks,
Fengguang


--ReaqsoxgOBHFXBhH
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="page-types.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <sys/fcntl.h>

#include "pagemap.h"

int main(int argc, char *argv[])
{
	static char kpageflags_name[] = "/proc/kpageflags";
	unsigned long i;
	uint64_t flags;
	int fd;

	fd = open(kpageflags_name, O_RDONLY);
	if (fd < 0) {
		perror(kpageflags_name);
		exit(1);
	}

	nr_pages = read(fd, kpageflags, sizeof(kpageflags));
	if (nr_pages <= 0) {
		perror(kpageflags_name);
		exit(2);
	}
	if (nr_pages % KPF_BYTES != 0) {
		fprintf(stderr, "%s: partial read: %lu bytes\n",
				argv[0], nr_pages);
		exit(3);
	}
	nr_pages = nr_pages / KPF_BYTES;

	for (i = 0; i < nr_pages; i++) {
		flags = kpageflags[i];

		if (flags >= ARRAY_SIZE(page_count)) {
			static int warned = 0;

			if (!warned) {
				warned = 1;
				fprintf(stderr, "%s: flags overflow: 0x%lx >= 0x%lx\n",
					argv[0], flags, ARRAY_SIZE(page_count));
				fprintf(stderr, "Either the kernel is buggy(<=2.6.28), "
					"or I'm too old to recognize new flags.\n\n");
			}

			flags = ARRAY_SIZE(page_count) - 1;
		}
		page_count[flags]++;
	}

#if 0
	for (i = 0; i < ARRAY_SIZE(page_flag_names); i++) {
		printf("%s ", page_flag_names[i]);
	}
#endif

	printf("   flags\tpage-count       MB  symbolic-flags             long-symbolic-flags\n");
	for (i = 0; i < ARRAY_SIZE(page_count); i++) {
		if (page_count[i])
			printf("0x%06lx\t%10lu %8lu  %s  %s\n",
				i,
				page_count[i],
				pages2mb(page_count[i]),
				page_flag_name(i),
				page_flag_longname(i));
	}

	printf("   total\t%10lu %8lu\n",
			nr_pages, pages2mb(nr_pages));

	return 0;
}

--ReaqsoxgOBHFXBhH
Content-Type: text/x-chdr; charset=us-ascii
Content-Disposition: attachment; filename="pagemap.h"


#define KPF_BYTES	8

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

/* copied from kpageflags_read() */

enum { 
        KPF_LOCKED,             /*  0 */
        KPF_ERROR,              /*  1 */
        KPF_REFERENCED,         /*  2 */
        KPF_UPTODATE,           /*  3 */
        KPF_DIRTY,              /*  4 */
        KPF_LRU,                /*  5 */
        KPF_ACTIVE,             /*  6 */
        KPF_SLAB,               /*  7 */
        KPF_WRITEBACK,          /*  8 */
        KPF_RECLAIM,            /*  9 */
        KPF_BUDDY,              /* 10 */
        KPF_MMAP,               /* 11 */
        KPF_SWAPCACHE,          /* 12 */
        KPF_SWAPBACKED,         /* 13 */
        KPF_MAPPEDTODISK,       /* 14 */
        KPF_RESERVED,           /* 15 */
        KPF_PRIVATE,            /* 16 */
        KPF_PRIVATE2,           /* 17 */
        KPF_OWNER_PRIVATE,      /* 18 */
        KPF_COMPOUND_HEAD,      /* 19 */
        KPF_COMPOUND_TAIL,      /* 20 */
        KPF_UNEVICTABLE,        /* 21 */
        KPF_MLOCKED,            /* 22 */
        KPF_POISON,             /* 23 */
        KPF_NOPAGE,             /* 24 */
        KPF_NUM
};

static char *page_flag_names[] = {
	[KPF_LOCKED]		= "L:locked",
	[KPF_ERROR]		= "E:error",
	[KPF_REFERENCED]	= "R:referenced",
	[KPF_UPTODATE]		= "U:uptodate",
	[KPF_DIRTY]		= "D:dirty",
	[KPF_LRU]		= "l:lru",
	[KPF_ACTIVE]		= "A:active",
	[KPF_SLAB]		= "S:slab",
	[KPF_WRITEBACK]		= "W:writeback",
	[KPF_RECLAIM]		= "x:reclaim",
	[KPF_BUDDY]		= "B:buddy",
	[KPF_RESERVED]		= "r:reserved",
	[KPF_SWAPCACHE]		= "c:swapcache",
	[KPF_SWAPBACKED]	= "b:swapbacked",
	[KPF_MAPPEDTODISK]	= "d:mappedtodisk",
	[KPF_PRIVATE]		= "P:private",
	[KPF_PRIVATE2]		= "p:private_2",
	[KPF_OWNER_PRIVATE]	= "O:owner_private",
	[KPF_COMPOUND_HEAD]	= "H:head",
	[KPF_COMPOUND_TAIL]	= "T:tail",
	[KPF_UNEVICTABLE]	= "u:unevictable",
	[KPF_MLOCKED]		= "M:mlocked",
	[KPF_MMAP]		= "m:mmap",
	[KPF_POISON]		= "X:poison",
	[KPF_NOPAGE]		= "n:nopage",
};

static unsigned long page_count[(1 << KPF_NUM)];
static unsigned long nr_pages;
static uint64_t kpageflags[KPF_BYTES * (16<<20)]; /* 64GB */

char *page_flag_name(uint64_t flags)
{
	int i;
	static char buf[64];

	for (i = 0; i < ARRAY_SIZE(page_flag_names); i++)
		buf[i] = (flags & (1 << i)) ? page_flag_names[i][0] : '_';

	return buf;
}

char *page_flag_longname(uint64_t flags)
{
	int i, n;
	static char buf[1024];

	for (i = 0, n = 0; i < ARRAY_SIZE(page_flag_names); i++)
		if (flags & (1<<i))
		       n += snprintf(buf + n, sizeof(buf) - n, "%s,",
				       page_flag_names[i] + 2);
	if (n)
		n--;
	buf[n] = '\0';

	return buf;
}

static unsigned long pages2kb(unsigned long pages)
{
	return (pages * getpagesize()) >> 10;
}

static unsigned long pages2mb(unsigned long pages)
{
	return (pages * getpagesize()) >> 20;
}


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=Makefile

BINS = page-types page-areas

all: $(BINS)

page-types: page-types.c pagemap.h
	gcc -g -o $@ $<

page-areas: page-areas.c pagemap.h
	gcc -g -o $@ $<

clean:
	rm $(BINS)

--ReaqsoxgOBHFXBhH
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="page-areas.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <sys/fcntl.h>

#include "pagemap.h"

static void add_index(unsigned long index)
{
	static unsigned long offset, len;

	if (index == offset + len)
		len++;
	else {
		if (len)
			printf("%10lu %8lu %8luKB\n", offset, len, pages2kb(len));
		offset = index;
		len = 1;
	}
}

static void usage(const char *prog)
{
	printf("Usage: %s page_flags\n", prog);
}

int main(int argc, char *argv[])
{
	static char kpageflags_name[] = "/proc/kpageflags";
	unsigned long match_flags, match_exact;
	unsigned long i;
	char *p;
	int fd;

	if (argc < 2) {
		usage(argv[0]);
		exit(1);
	}

	match_exact = 0;
	p = argv[1];
	if (p[0] == '=') {
		match_exact = 1;
		p++;
	}
	match_flags = strtol(p, 0, 16);

	fd = open(kpageflags_name, O_RDONLY);
	if (fd < 0) {
		perror(kpageflags_name);
		exit(1);
	}

	nr_pages = read(fd, kpageflags, sizeof(kpageflags));
	if (nr_pages <= 0) {
		perror(kpageflags_name);
		exit(2);
	}
	if (nr_pages % KPF_BYTES != 0) {
		fprintf(stderr, "%s: partial read: %lu bytes\n",
				argv[0], nr_pages);
		exit(3);
	}
	nr_pages = nr_pages / KPF_BYTES;

	printf("    offset      len         KB\n");
	for (i = 0; i < nr_pages; i++) {
		if (!match_exact && ((kpageflags[i] & match_flags) == match_flags) ||
		    (match_exact && kpageflags[i] == match_flags))
			add_index(i);
	}
	add_index(0);

	return 0;
}

--ReaqsoxgOBHFXBhH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
