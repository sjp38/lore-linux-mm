Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 010816B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 03:19:33 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so5483518pbb.35
        for <linux-mm@kvack.org>; Mon, 19 May 2014 00:19:33 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fk10si18328248pac.225.2014.05.19.00.19.32
        for <linux-mm@kvack.org>;
        Mon, 19 May 2014 00:19:32 -0700 (PDT)
Date: Mon, 19 May 2014 15:18:25 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 446/499] mm/nommu.c:97:8: warning: (near
 initialization for 'nommu_region_sem')
Message-ID: <5379b041.l+0HY3AnwO7I7qpR%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   ff35dad6205c66d96feda494502753e5ed1b10f1
commit: 67039d034b422b074af336ebf8101346b6b5d441 [446/499] rwsem: Support optimistic spinning
config: make ARCH=blackfin BF561-EZKIT-SMP_defconfig

All warnings:

   mm/nommu.c:97:8: warning: excess elements in struct initializer [enabled by default]
>> mm/nommu.c:97:8: warning: (near initialization for 'nommu_region_sem') [enabled by default]
   mm/nommu.c:97:8: warning: excess elements in struct initializer [enabled by default]
>> mm/nommu.c:97:8: warning: (near initialization for 'nommu_region_sem') [enabled by default]

vim +/nommu_region_sem +97 mm/nommu.c

997071bc K. Y. Srinivasan 2012-11-15   81   * balancing memory across competing virtual machines that are hosted.
997071bc K. Y. Srinivasan 2012-11-15   82   * Several metrics drive this policy engine including the guest reported
997071bc K. Y. Srinivasan 2012-11-15   83   * memory commitment.
997071bc K. Y. Srinivasan 2012-11-15   84   */
997071bc K. Y. Srinivasan 2012-11-15   85  unsigned long vm_memory_committed(void)
997071bc K. Y. Srinivasan 2012-11-15   86  {
997071bc K. Y. Srinivasan 2012-11-15   87  	return percpu_counter_read_positive(&vm_committed_as);
997071bc K. Y. Srinivasan 2012-11-15   88  }
997071bc K. Y. Srinivasan 2012-11-15   89  
997071bc K. Y. Srinivasan 2012-11-15   90  EXPORT_SYMBOL_GPL(vm_memory_committed);
997071bc K. Y. Srinivasan 2012-11-15   91  
^1da177e Linus Torvalds   2005-04-16   92  EXPORT_SYMBOL(mem_map);
^1da177e Linus Torvalds   2005-04-16   93  
8feae131 David Howells    2009-01-08   94  /* list of mapped, potentially shareable regions */
8feae131 David Howells    2009-01-08   95  static struct kmem_cache *vm_region_jar;
8feae131 David Howells    2009-01-08   96  struct rb_root nommu_region_tree = RB_ROOT;
8feae131 David Howells    2009-01-08  @97  DECLARE_RWSEM(nommu_region_sem);
^1da177e Linus Torvalds   2005-04-16   98  
f0f37e2f Alexey Dobriyan  2009-09-27   99  const struct vm_operations_struct generic_file_vm_ops = {
^1da177e Linus Torvalds   2005-04-16  100  };
^1da177e Linus Torvalds   2005-04-16  101  
^1da177e Linus Torvalds   2005-04-16  102  /*
^1da177e Linus Torvalds   2005-04-16  103   * Return the total memory allocated for this pointer, not
^1da177e Linus Torvalds   2005-04-16  104   * just what the caller asked for.
^1da177e Linus Torvalds   2005-04-16  105   *

:::::: The code at line 97 was first introduced by commit
:::::: 8feae13110d60cc6287afabc2887366b0eb226c2 NOMMU: Make VMAs per MM as for MMU-mode linux

:::::: TO: David Howells <dhowells@redhat.com>
:::::: CC: David Howells <dhowells@redhat.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
