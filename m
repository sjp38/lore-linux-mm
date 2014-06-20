Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF6D76B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 05:23:51 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so2924755pad.10
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 02:23:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id df3si8952565pbb.203.2014.06.20.02.23.50
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 02:23:51 -0700 (PDT)
Date: Fri, 20 Jun 2014 17:23:45 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 182/217] arch/powerpc/boot/types.h:18:14: warning:
 comparison of distinct pointer types lacks a cast
Message-ID: <53a3fda1.xVZderbgEd9yLzdT%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   633594bb2d3890711a887897f2003f41735f0dfa
commit: 8d9dfa4b0125b04eb215909a388cf83fcdeee719 [182/217] initramfs: support initramfs that is more than 2G
config: make ARCH=powerpc mpc86xx_defconfig

All warnings:

   In file included from arch/powerpc/boot/ops.h:15:0,
                    from arch/powerpc/boot/gunzip_util.c:14:
   arch/powerpc/boot/gunzip_util.c: In function 'gunzip_partial':
>> arch/powerpc/boot/types.h:18:14: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_x == &_y); \
                 ^
>> arch/powerpc/boot/gunzip_util.c:118:9: note: in expansion of macro 'min'
      len = min(state->s.avail_in, (unsigned)dstlen);
            ^

vim +18 arch/powerpc/boot/types.h

b2c5f619 Mark A. Greer 2006-09-19   2  #define _TYPES_H_
b2c5f619 Mark A. Greer 2006-09-19   3  
b2c5f619 Mark A. Greer 2006-09-19   4  #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
b2c5f619 Mark A. Greer 2006-09-19   5  
b2c5f619 Mark A. Greer 2006-09-19   6  typedef unsigned char		u8;
b2c5f619 Mark A. Greer 2006-09-19   7  typedef unsigned short		u16;
b2c5f619 Mark A. Greer 2006-09-19   8  typedef unsigned int		u32;
b2c5f619 Mark A. Greer 2006-09-19   9  typedef unsigned long long	u64;
72d06895 Geoff Levand  2007-06-16  10  typedef signed char		s8;
72d06895 Geoff Levand  2007-06-16  11  typedef short			s16;
72d06895 Geoff Levand  2007-06-16  12  typedef int			s32;
72d06895 Geoff Levand  2007-06-16  13  typedef long long		s64;
b2c5f619 Mark A. Greer 2006-09-19  14  
b2c5f619 Mark A. Greer 2006-09-19  15  #define min(x,y) ({ \
b2c5f619 Mark A. Greer 2006-09-19  16  	typeof(x) _x = (x);	\
b2c5f619 Mark A. Greer 2006-09-19  17  	typeof(y) _y = (y);	\
b2c5f619 Mark A. Greer 2006-09-19 @18  	(void) (&_x == &_y);	\
b2c5f619 Mark A. Greer 2006-09-19  19  	_x < _y ? _x : _y; })
b2c5f619 Mark A. Greer 2006-09-19  20  
b2c5f619 Mark A. Greer 2006-09-19  21  #define max(x,y) ({ \
b2c5f619 Mark A. Greer 2006-09-19  22  	typeof(x) _x = (x);	\
b2c5f619 Mark A. Greer 2006-09-19  23  	typeof(y) _y = (y);	\
b2c5f619 Mark A. Greer 2006-09-19  24  	(void) (&_x == &_y);	\
b2c5f619 Mark A. Greer 2006-09-19  25  	_x > _y ? _x : _y; })
b2c5f619 Mark A. Greer 2006-09-19  26  

:::::: The code at line 18 was first introduced by commit
:::::: b2c5f61920eeee9c4e78698de4fde4586fe5ae79 [POWERPC] Start arch/powerpc/boot code reorganization

:::::: TO: Mark A. Greer <mgreer@mvista.com>
:::::: CC: Paul Mackerras <paulus@samba.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
