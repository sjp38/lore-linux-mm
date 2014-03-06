Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id A340E6B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 22:25:02 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so1963810pbb.8
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 19:25:02 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id ra2si3934138pab.211.2014.03.05.19.25.01
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 19:25:01 -0800 (PST)
Date: Thu, 06 Mar 2014 11:24:56 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 188/471] include/linux/swap.h:33:16: error:
 dereferencing pointer to incomplete type
Message-ID: <5317ea88.Pvq6lNAdz5mv4Fdd%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   f6bf2766c2091cbf8ffcc2c5009875dbdb678282
commit: 88a76abced8c721ac726ea6a273ed0389b1c5ff4 [188/471] mm: per-thread vma caching
config: make ARCH=sparc defconfig

All error/warnings:

   In file included from arch/sparc/include/asm/pgtable_32.h:17:0,
                    from arch/sparc/include/asm/pgtable.h:6,
                    from include/linux/mm.h:51,
                    from include/linux/vmacache.h:4,
                    from include/linux/sched.h:26,
                    from arch/sparc/kernel/asm-offsets.c:13:
   include/linux/swap.h: In function 'current_is_kswapd':
>> include/linux/swap.h:33:16: error: dereferencing pointer to incomplete type
>> include/linux/swap.h:33:26: error: 'PF_KSWAPD' undeclared (first use in this function)
   include/linux/swap.h:33:26: note: each undeclared identifier is reported only once for each function it appears in
   make[2]: *** [arch/sparc/kernel/asm-offsets.s] Error 1
   make[2]: Target `__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target `prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +33 include/linux/swap.h

8bc719d3 Martin Schwidefsky 2006-09-25  17  
ab954160 Andrew Morton      2006-09-25  18  struct bio;
ab954160 Andrew Morton      2006-09-25  19  
^1da177e Linus Torvalds     2005-04-16  20  #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
^1da177e Linus Torvalds     2005-04-16  21  #define SWAP_FLAG_PRIO_MASK	0x7fff
^1da177e Linus Torvalds     2005-04-16  22  #define SWAP_FLAG_PRIO_SHIFT	0
dcf6b7dd Rafael Aquini      2013-07-03  23  #define SWAP_FLAG_DISCARD	0x10000 /* enable discard for swap */
dcf6b7dd Rafael Aquini      2013-07-03  24  #define SWAP_FLAG_DISCARD_ONCE	0x20000 /* discard swap area at swapon-time */
dcf6b7dd Rafael Aquini      2013-07-03  25  #define SWAP_FLAG_DISCARD_PAGES 0x40000 /* discard page-clusters after use */
^1da177e Linus Torvalds     2005-04-16  26  
d15cab97 Hugh Dickins       2012-03-28  27  #define SWAP_FLAGS_VALID	(SWAP_FLAG_PRIO_MASK | SWAP_FLAG_PREFER | \
dcf6b7dd Rafael Aquini      2013-07-03  28  				 SWAP_FLAG_DISCARD | SWAP_FLAG_DISCARD_ONCE | \
dcf6b7dd Rafael Aquini      2013-07-03  29  				 SWAP_FLAG_DISCARD_PAGES)
d15cab97 Hugh Dickins       2012-03-28  30  
^1da177e Linus Torvalds     2005-04-16  31  static inline int current_is_kswapd(void)
^1da177e Linus Torvalds     2005-04-16  32  {
^1da177e Linus Torvalds     2005-04-16 @33  	return current->flags & PF_KSWAPD;
^1da177e Linus Torvalds     2005-04-16  34  }
^1da177e Linus Torvalds     2005-04-16  35  
^1da177e Linus Torvalds     2005-04-16  36  /*
^1da177e Linus Torvalds     2005-04-16  37   * MAX_SWAPFILES defines the maximum number of swaptypes: things which can
^1da177e Linus Torvalds     2005-04-16  38   * be swapped to.  The swap type and the offset into that swap type are
^1da177e Linus Torvalds     2005-04-16  39   * encoded into pte's and into pgoff_t's in the swapcache.  Using five bits
^1da177e Linus Torvalds     2005-04-16  40   * for the type means that the maximum number of swapcache pages is 27 bits
^1da177e Linus Torvalds     2005-04-16  41   * on 32-bit-pgoff_t architectures.  And that assumes that the architecture packs

:::::: The code at line 33 was first introduced by commit
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
