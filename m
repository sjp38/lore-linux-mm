Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0A16B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 19:02:09 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id md12so1217855pbc.5
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:02:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id in9si3648277pbd.29.2014.06.18.16.02.08
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 16:02:08 -0700 (PDT)
Date: Thu, 19 Jun 2014 07:01:18 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32'
 undeclared
Message-ID: <53a21a3e.1HJ5drRU6UL26Oem%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Woods <wwoods@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   e99cfa2d0634881b8a41d56c48b5956b9a3ba162
commit: 1e2ee49f7f1b79f0b14884fe6a602f0411b39552 fanotify: fix -EOVERFLOW with large files on 64-bit
date:   6 weeks ago
config: make ARCH=ia64 allmodconfig

All error/warnings:

   fs/notify/fanotify/fanotify_user.c: In function 'SYSC_fanotify_init':
   fs/notify/fanotify/fanotify_user.c:701:2: error: implicit declaration of function 'personality' [-Werror=implicit-function-declaration]
     if (force_o_largefile())
     ^
   In file included from include/uapi/linux/fcntl.h:4:0,
                    from include/linux/fcntl.h:4,
                    from fs/notify/fanotify/fanotify_user.c:2:
>> arch/ia64/include/uapi/asm/fcntl.h:9:41: error: 'PER_LINUX32' undeclared (first use in this function)
      (personality(current->personality) != PER_LINUX32)
                                            ^
   fs/notify/fanotify/fanotify_user.c:701:6: note: in expansion of macro 'force_o_largefile'
     if (force_o_largefile())
         ^
   arch/ia64/include/uapi/asm/fcntl.h:9:41: note: each undeclared identifier is reported only once for each function it appears in
      (personality(current->personality) != PER_LINUX32)
                                            ^
   fs/notify/fanotify/fanotify_user.c:701:6: note: in expansion of macro 'force_o_largefile'
     if (force_o_largefile())
         ^
   cc1: some warnings being treated as errors

vim +/PER_LINUX32 +9 arch/ia64/include/uapi/asm/fcntl.h

^1da177e include/asm-ia64/fcntl.h Linus Torvalds   2005-04-16   1  #ifndef _ASM_IA64_FCNTL_H
^1da177e include/asm-ia64/fcntl.h Linus Torvalds   2005-04-16   2  #define _ASM_IA64_FCNTL_H
^1da177e include/asm-ia64/fcntl.h Linus Torvalds   2005-04-16   3  /*
^1da177e include/asm-ia64/fcntl.h Linus Torvalds   2005-04-16   4   * Modified 1998-2000
^1da177e include/asm-ia64/fcntl.h Linus Torvalds   2005-04-16   5   *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co.
^1da177e include/asm-ia64/fcntl.h Linus Torvalds   2005-04-16   6   */
^1da177e include/asm-ia64/fcntl.h Linus Torvalds   2005-04-16   7  
ff67b597 include/asm-ia64/fcntl.h Tony Luck        2005-08-30   8  #define force_o_largefile()	\
ff67b597 include/asm-ia64/fcntl.h Tony Luck        2005-08-30  @9  		(personality(current->personality) != PER_LINUX32)
ef3daeda include/asm-ia64/fcntl.h Yoav Zach        2005-06-23  10  
9317259e include/asm-ia64/fcntl.h Stephen Rothwell 2005-09-06  11  #include <asm-generic/fcntl.h>
9317259e include/asm-ia64/fcntl.h Stephen Rothwell 2005-09-06  12  
^1da177e include/asm-ia64/fcntl.h Linus Torvalds   2005-04-16  13  #endif /* _ASM_IA64_FCNTL_H */

:::::: The code at line 9 was first introduced by commit
:::::: ff67b59726a8cd3549b069dfa78de2f538d3b8e3 [IA64] Low byte of current->personality is not a bitmask.

:::::: TO: Tony Luck <tony.luck@intel.com>
:::::: CC: Tony Luck <tony.luck@intel.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
