Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id AC84E28027E
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 05:11:03 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so41241963pdj.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 02:11:03 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bs11si12027072pdb.26.2015.07.16.02.11.02
        for <linux-mm@kvack.org>;
        Thu, 16 Jul 2015 02:11:02 -0700 (PDT)
Date: Thu, 16 Jul 2015 17:10:30 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 2811/2969] lib/test-parse-integer.c:118:57:
 sparse: constant 4294967296 is so big it is long
Message-ID: <201507161728.QVcHY3Ks%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   6593e2dcdedd0493e1b1fcb419609d2101c4d0be
commit: 8b4d3eb762c8ab82d175c2f410323f84aa775dc0 [2811/2969] parse_integer: add runtime testsuite
reproduce:
  # apt-get install sparse
  git checkout 8b4d3eb762c8ab82d175c2f410323f84aa775dc0
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> lib/test-parse-integer.c:118:57: sparse: constant 4294967296 is so big it is long
   lib/test-parse-integer.c:119:57: sparse: constant 9223372036854775807 is so big it is long
   lib/test-parse-integer.c:134:57: sparse: constant 040000000000 is so big it is long
   lib/test-parse-integer.c:135:57: sparse: constant 0777777777777777777777 is so big it is long
>> lib/test-parse-integer.c:136:57: sparse: constant 01000000000000000000000 is so big it is unsigned long
   lib/test-parse-integer.c:137:57: sparse: constant 01777777777777777777777 is so big it is unsigned long
   lib/test-parse-integer.c:150:49: sparse: constant 0x100000000 is so big it is long
   lib/test-parse-integer.c:151:49: sparse: constant 0x7fffffffffffffff is so big it is long
   lib/test-parse-integer.c:152:49: sparse: constant 0x8000000000000000 is so big it is unsigned long
   lib/test-parse-integer.c:153:49: sparse: constant 0xffffffffffffffff is so big it is unsigned long
   lib/test-parse-integer.c:287:50: sparse: constant 4294967296 is so big it is long
   lib/test-parse-integer.c:301:49: sparse: constant 9223372036854775807 is so big it is long

vim +118 lib/test-parse-integer.c

   112		{"32768",			10,	5,	32768},
   113		{"65535",			10,	5,	65535},
   114		{"65536",			10,	5,	65536},
   115		{"2147483647",			10,	10,	2147483647},
   116		{"2147483648",			10,	10,	2147483648ull},
   117		{"4294967295",			10,	10,	4294967295ull},
 > 118		{"4294967296",			10,	10,	4294967296},
   119		{"9223372036854775807",		10,	19,	9223372036854775807},
   120		{"9223372036854775808",		10,	19,	9223372036854775808ull},
   121		{"18446744073709551615",	10,	20,	18446744073709551615ull},
   122	
   123		{"177",				8,	3,	0177},
   124		{"200",				8,	3,	0200},
   125		{"377",				8,	3,	0377},
   126		{"400",				8,	3,	0400},
   127		{"77777",			8,	5,	077777},
   128		{"100000",			8,	6,	0100000},
   129		{"177777",			8,	6,	0177777},
   130		{"200000",			8,	6,	0200000},
   131		{"17777777777",			8,	11,	017777777777},
   132		{"20000000000",			8,	11,	020000000000},
   133		{"37777777777",			8,	11,	037777777777},
   134		{"40000000000",			8,	11,	040000000000},
   135		{"777777777777777777777",	8,	21,	0777777777777777777777},
 > 136		{"1000000000000000000000",	8,	22,	01000000000000000000000},
   137		{"1777777777777777777777",	8,	22,	01777777777777777777777},
   138	
   139		{"7f",			16,	2,	0x7f},

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
