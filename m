Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C86056B0036
	for <linux-mm@kvack.org>; Fri,  9 May 2014 22:35:49 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5146450pad.30
        for <linux-mm@kvack.org>; Fri, 09 May 2014 19:35:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id nw5si796077pbb.16.2014.05.09.19.35.48
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 19:35:48 -0700 (PDT)
Date: Sat, 10 May 2014 10:32:41 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 230/459] include/linux/radix-tree.h:260:9: sparse:
 incorrect type in assignment (different address spaces)
Message-ID: <536d8fc9.irVvmfyfuwCw+szX%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes.berg@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   9567896580328249f6519fda78cf9fe185a8486d
commit: 849ba771e4fd9d334940e79d19c824608d06d393 [230/459] compiler.h: don't use temporary variable in __compiletime_assert()
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> include/linux/radix-tree.h:260:9: sparse: incorrect type in assignment (different address spaces)
   include/linux/radix-tree.h:260:9:    expected void *volatile <noident>
   include/linux/radix-tree.h:260:9:    got void [noderef] <asn:4>*<noident>
>> include/linux/radix-tree.h:260:9: sparse: incorrect type in assignment (different address spaces)
   include/linux/radix-tree.h:260:9:    expected void *volatile <noident>
   include/linux/radix-tree.h:260:9:    got void [noderef] <asn:4>*<noident>
   include/linux/radix-tree.h:212:16: sparse: incompatible types in comparison expression (different address spaces)
   include/linux/radix-tree.h:196:16: sparse: incompatible types in comparison expression (different address spaces)
   include/linux/radix-tree.h:196:16: sparse: incompatible types in comparison expression (different address spaces)
   include/linux/radix-tree.h:196:16: sparse: incompatible types in comparison expression (different address spaces)
   include/linux/radix-tree.h:196:16: sparse: incompatible types in comparison expression (different address spaces)
   include/linux/radix-tree.h:196:16: sparse: incompatible types in comparison expression (different address spaces)
   include/linux/radix-tree.h:196:16: sparse: incompatible types in comparison expression (different address spaces)
--
>> include/linux/radix-tree.h:260:9: sparse: incorrect type in assignment (different address spaces)
   include/linux/radix-tree.h:260:9:    expected void *volatile <noident>
   include/linux/radix-tree.h:260:9:    got void [noderef] <asn:4>*<noident>
--
>> drivers/md/dm-era-target.c:640:9: sparse: incorrect type in assignment (different address spaces)
   drivers/md/dm-era-target.c:640:9:    expected struct writeset *volatile <noident>
   drivers/md/dm-era-target.c:640:9:    got struct writeset [noderef] <asn:4>*<noident>
   drivers/md/dm-era-target.c:939:14: sparse: incompatible types in comparison expression (different address spaces)

vim +260 include/linux/radix-tree.h

6328650b Hugh Dickins    2011-08-03  244  {
6328650b Hugh Dickins    2011-08-03  245  	return unlikely((unsigned long)arg &
6328650b Hugh Dickins    2011-08-03  246  		(RADIX_TREE_INDIRECT_PTR | RADIX_TREE_EXCEPTIONAL_ENTRY));
6328650b Hugh Dickins    2011-08-03  247  }
6328650b Hugh Dickins    2011-08-03  248  
6328650b Hugh Dickins    2011-08-03  249  /**
7cf9c2c7 Nick Piggin     2006-12-06  250   * radix_tree_replace_slot	- replace item in a slot
7cf9c2c7 Nick Piggin     2006-12-06  251   * @pslot:	pointer to slot, returned by radix_tree_lookup_slot
7cf9c2c7 Nick Piggin     2006-12-06  252   * @item:	new item to store in the slot.
7cf9c2c7 Nick Piggin     2006-12-06  253   *
7cf9c2c7 Nick Piggin     2006-12-06  254   * For use with radix_tree_lookup_slot().  Caller must hold tree write locked
7cf9c2c7 Nick Piggin     2006-12-06  255   * across slot lookup and replacement.
7cf9c2c7 Nick Piggin     2006-12-06  256   */
7cf9c2c7 Nick Piggin     2006-12-06  257  static inline void radix_tree_replace_slot(void **pslot, void *item)
7cf9c2c7 Nick Piggin     2006-12-06  258  {
c0bc9875 Nick Piggin     2007-10-16  259  	BUG_ON(radix_tree_is_indirect_ptr(item));
c0bc9875 Nick Piggin     2007-10-16 @260  	rcu_assign_pointer(*pslot, item);
7cf9c2c7 Nick Piggin     2006-12-06  261  }
7cf9c2c7 Nick Piggin     2006-12-06  262  
139e5616 Johannes Weiner 2014-04-03  263  int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
139e5616 Johannes Weiner 2014-04-03  264  			struct radix_tree_node **nodep, void ***slotp);
^1da177e Linus Torvalds  2005-04-16  265  int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
139e5616 Johannes Weiner 2014-04-03  266  void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
139e5616 Johannes Weiner 2014-04-03  267  			  struct radix_tree_node **nodep, void ***slotp);
^1da177e Linus Torvalds  2005-04-16  268  void *radix_tree_lookup(struct radix_tree_root *, unsigned long);

:::::: The code at line 260 was first introduced by commit
:::::: c0bc9875b701c588e448302d41181995c21e8040 radix-tree: use indirect bit

:::::: TO: Nick Piggin <npiggin@suse.de>
:::::: CC: Linus Torvalds <torvalds@woody.linux-foundation.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
