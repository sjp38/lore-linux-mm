Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1A76B0073
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:22:02 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so10476061pbb.8
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 01:22:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id iw3si12265102pac.301.2014.04.16.01.22.00
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 01:22:01 -0700 (PDT)
Date: Wed, 16 Apr 2014 14:59:58 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 103/113] include/linux/blkdev.h:25:29: fatal error:
 asm/scatterlist.h: No such file or directory
Message-ID: <534e2a6e.Ldm85XovY2CX2Ogp%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   2db08cc65391d73dc8cbcaefdb55c42a774d9e1a
commit: ff35bd54456e18878c361a8a2deeb41c9688458f [103/113] lib/scatterlist: make ARCH_HAS_SG_CHAIN an actual Kconfig
config: make ARCH=um SUBARCH=i386 defconfig

All error/warnings:

   In file included from init/main.c:75:0:
>> include/linux/blkdev.h:25:29: fatal error: asm/scatterlist.h: No such file or directory
    #include <asm/scatterlist.h>
                                ^
   compilation terminated.
--
   In file included from mm/page_io.c:19:0:
   include/linux/swapops.h: In function 'is_swap_pte':
   include/linux/swapops.h:57:2: error: implicit declaration of function 'pte_present_nonuma' [-Werror=implicit-function-declaration]
     return !pte_none(pte) && !pte_present_nonuma(pte) && !pte_file(pte);
     ^
   In file included from mm/page_io.c:24:0:
   include/linux/blkdev.h: At top level:
>> include/linux/blkdev.h:25:29: fatal error: asm/scatterlist.h: No such file or directory
    #include <asm/scatterlist.h>
                                ^
   cc1: some warnings being treated as errors
   compilation terminated.

vim +25 include/linux/blkdev.h

^1da177e Linus Torvalds    2005-04-16   9  #include <linux/genhd.h>
^1da177e Linus Torvalds    2005-04-16  10  #include <linux/list.h>
320ae51f Jens Axboe        2013-10-24  11  #include <linux/llist.h>
^1da177e Linus Torvalds    2005-04-16  12  #include <linux/timer.h>
^1da177e Linus Torvalds    2005-04-16  13  #include <linux/workqueue.h>
^1da177e Linus Torvalds    2005-04-16  14  #include <linux/pagemap.h>
^1da177e Linus Torvalds    2005-04-16  15  #include <linux/backing-dev.h>
^1da177e Linus Torvalds    2005-04-16  16  #include <linux/wait.h>
^1da177e Linus Torvalds    2005-04-16  17  #include <linux/mempool.h>
^1da177e Linus Torvalds    2005-04-16  18  #include <linux/bio.h>
^1da177e Linus Torvalds    2005-04-16  19  #include <linux/stringify.h>
3e6053d7 Hugh Dickins      2008-09-11  20  #include <linux/gfp.h>
d351af01 FUJITA Tomonori   2007-07-09  21  #include <linux/bsg.h>
c7c22e4d Jens Axboe        2008-09-13  22  #include <linux/smp.h>
548bc8e1 Tejun Heo         2013-01-09  23  #include <linux/rcupdate.h>
^1da177e Linus Torvalds    2005-04-16  24  
^1da177e Linus Torvalds    2005-04-16 @25  #include <asm/scatterlist.h>
^1da177e Linus Torvalds    2005-04-16  26  
de477254 Paul Gortmaker    2011-05-26  27  struct module;
21b2f0c8 Christoph Hellwig 2006-03-22  28  struct scsi_ioctl_command;
21b2f0c8 Christoph Hellwig 2006-03-22  29  
^1da177e Linus Torvalds    2005-04-16  30  struct request_queue;
^1da177e Linus Torvalds    2005-04-16  31  struct elevator_queue;
^1da177e Linus Torvalds    2005-04-16  32  struct request_pm_state;
2056a782 Jens Axboe        2006-03-23  33  struct blk_trace;

:::::: The code at line 25 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
