Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CC19E6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 20:42:27 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kl14so4096104pab.27
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 17:42:27 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kn7si5426576pbc.336.2014.01.09.17.42.25
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 17:42:26 -0800 (PST)
Date: Fri, 10 Jan 2014 09:42:23 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 222/422] include/linux/kernel.h:792:27: error:
 'struct request' has no member named 'll_list'
Message-ID: <52cf4fff.JLNAamcD+Xy0OqLd%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   3fe55fa60ae65a3c8348ae1bfc6fd2e5c3f10654
commit: 40d1f543e14f53f9045b6a366f533dd878cf5212 [222/422] kernel: use lockless list for smp_call_function_single
config: make ARCH=x86_64 allnoconfig

Note: the mmotm/master HEAD 3fe55fa60ae65a3c8348ae1bfc6fd2e5c3f10654 builds fine.
      It only hurts bisectibility.

All error/warnings:

   In file included from block/blk-mq-cpu.c:1:0:
   block/blk-mq-cpu.c: In function 'blk_mq_cpu_notify':
>> include/linux/kernel.h:792:27: error: 'struct request' has no member named 'll_list'
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                              ^
   include/linux/llist.h:88:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^
   block/blk-mq-cpu.c:48:9: note: in expansion of macro 'llist_entry'
       rq = llist_entry(node, struct request, ll_list);
            ^
   include/linux/kernel.h:792:48: warning: initialization from incompatible pointer type [enabled by default]
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                                                   ^
   include/linux/llist.h:88:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^
   block/blk-mq-cpu.c:48:9: note: in expansion of macro 'llist_entry'
       rq = llist_entry(node, struct request, ll_list);
            ^
   In file included from include/linux/compiler-gcc.h:103:0,
                    from include/linux/compiler.h:54,
                    from include/linux/linkage.h:4,
                    from include/linux/kernel.h:6,
                    from block/blk-mq-cpu.c:1:
>> include/linux/compiler-gcc4.h:14:34: error: 'struct request' has no member named 'll_list'
    #define __compiler_offsetof(a,b) __builtin_offsetof(a,b)
                                     ^
   include/linux/stddef.h:17:31: note: in expansion of macro '__compiler_offsetof'
    #define offsetof(TYPE,MEMBER) __compiler_offsetof(TYPE,MEMBER)
                                  ^
   include/linux/kernel.h:793:29: note: in expansion of macro 'offsetof'
     (type *)( (char *)__mptr - offsetof(type,member) );})
                                ^
   include/linux/llist.h:88:2: note: in expansion of macro 'container_of'
     container_of(ptr, type, member)
     ^
   block/blk-mq-cpu.c:48:9: note: in expansion of macro 'llist_entry'
       rq = llist_entry(node, struct request, ll_list);
            ^

vim +792 include/linux/kernel.h

^1da177e Linus Torvalds 2005-04-16  786   * @ptr:	the pointer to the member.
^1da177e Linus Torvalds 2005-04-16  787   * @type:	the type of the container struct this is embedded in.
^1da177e Linus Torvalds 2005-04-16  788   * @member:	the name of the member within the struct.
^1da177e Linus Torvalds 2005-04-16  789   *
^1da177e Linus Torvalds 2005-04-16  790   */
^1da177e Linus Torvalds 2005-04-16  791  #define container_of(ptr, type, member) ({			\
78db2ad6 Daniel Walker  2007-05-12 @792  	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
78db2ad6 Daniel Walker  2007-05-12  793  	(type *)( (char *)__mptr - offsetof(type,member) );})
^1da177e Linus Torvalds 2005-04-16  794  
b9d4f426 Arnaud Lacombe 2011-07-25  795  /* Trap pasters of __FUNCTION__ at compile-time */

:::::: The code at line 792 was first introduced by commit
:::::: 78db2ad6f4df9145bfd6aab1c0f1c56d615288ec include/linux: trivial repair whitespace damage

:::::: TO: Daniel Walker <dwalker@mvista.com>
:::::: CC: Linus Torvalds <torvalds@woody.linux-foundation.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
