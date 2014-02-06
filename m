Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF3A86B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 22:54:16 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so1180522pab.38
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 19:54:16 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tq5si31350460pac.124.2014.02.05.19.54.15
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 19:54:15 -0800 (PST)
Date: Thu, 06 Feb 2014 11:54:12 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 19/141] drivers/md/bcache/btree.c:1816:16: sparse:
 incompatible types in comparison expression (different type sizes)
Message-ID: <52f30764.RmiGkco1KAthHSZ5%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   9b06d5ead85e27b8c1e2f8c514b73ebf7de8acd4
commit: e478d30d1922fa14c062d0c26e051e1f2a8a892e [19/141] drivers/md/bcache/btree.c: drop L-suffix when comparing ssize_t with 0
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/md/bcache/btree.c:1816:16: sparse: incompatible types in comparison expression (different type sizes)
   In file included from arch/x86/include/asm/percpu.h:44:0,
                    from arch/x86/include/asm/preempt.h:5,
                    from include/linux/preempt.h:18,
                    from include/linux/spinlock.h:50,
                    from include/linux/wait.h:8,
                    from include/linux/fs.h:6,
                    from include/linux/highmem.h:4,
                    from include/linux/bio.h:23,
                    from drivers/md/bcache/bcache.h:181,
                    from drivers/md/bcache/btree.c:23:
   drivers/md/bcache/btree.c: In function 'insert_u64s_remaining':
   include/linux/kernel.h:718:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_max1 == &_max2);  \
                    ^
   drivers/md/bcache/btree.c:1816:9: note: in expansion of macro 'max'
     return max(ret, 0);
            ^

vim +1816 drivers/md/bcache/btree.c

  1800						      status);
  1801			return true;
  1802		} else
  1803			return false;
  1804	}
  1805	
  1806	static size_t insert_u64s_remaining(struct btree *b)
  1807	{
  1808		ssize_t ret = bch_btree_keys_u64s_remaining(&b->keys);
  1809	
  1810		/*
  1811		 * Might land in the middle of an existing extent and have to split it
  1812		 */
  1813		if (b->keys.ops->is_extents)
  1814			ret -= KEY_MAX_U64S;
  1815	
> 1816		return max(ret, 0);
  1817	}
  1818	
  1819	static bool bch_btree_insert_keys(struct btree *b, struct btree_op *op,
  1820					  struct keylist *insert_keys,
  1821					  struct bkey *replace_key)
  1822	{
  1823		bool ret = false;
  1824		int oldsize = bch_count_data(&b->keys);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
