Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 81BA26B006E
	for <linux-mm@kvack.org>; Sun, 26 Apr 2015 23:17:50 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so114478802pac.1
        for <linux-mm@kvack.org>; Sun, 26 Apr 2015 20:17:50 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id qv8si27848369pbb.3.2015.04.26.20.17.49
        for <linux-mm@kvack.org>;
        Sun, 26 Apr 2015 20:17:49 -0700 (PDT)
Date: Mon, 27 Apr 2015 11:17:25 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: mm/memtest.c:84:33: sparse: cast from restricted __be64
Message-ID: <201504271121.cJcpJ8K4%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   b787f68c36d49bb1d9236f403813641efa74a031
commit: 4a20799d11f64e6b8725cacc7619b1ae1dbf9acd mm: move memtest under mm
date:   12 days ago
reproduce:
  # apt-get install sparse
  git checkout 4a20799d11f64e6b8725cacc7619b1ae1dbf9acd
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/memtest.c:84:33: sparse: cast from restricted __be64

vim +84 mm/memtest.c

7dad169e arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  68  	if (start_bad)
7dad169e arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  69  		reserve_bad_mem(pattern, start_bad, last_bad + incr);
1f067167 arch/x86/mm/memtest.c Yinghai Lu        2008-07-15  70  }
1f067167 arch/x86/mm/memtest.c Yinghai Lu        2008-07-15  71  
bfb4dc0d arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  72  static void __init do_one_pass(u64 pattern, u64 start, u64 end)
bfb4dc0d arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  73  {
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  74  	u64 i;
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  75  	phys_addr_t this_start, this_end;
bfb4dc0d arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  76  
9a28f9dc arch/x86/mm/memtest.c Grygorii Strashko 2014-01-21  77  	for_each_free_mem_range(i, NUMA_NO_NODE, &this_start, &this_end, NULL) {
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  78  		this_start = clamp_t(phys_addr_t, this_start, start, end);
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  79  		this_end = clamp_t(phys_addr_t, this_end, start, end);
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  80  		if (this_start < this_end) {
bfb4dc0d arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  81  			printk(KERN_INFO "  %010llx - %010llx pattern %016llx\n",
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  82  			       (unsigned long long)this_start,
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  83  			       (unsigned long long)this_end,
bfb4dc0d arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25 @84  			       (unsigned long long)cpu_to_be64(pattern));
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  85  			memtest(pattern, this_start, this_end - this_start);
8d89ac80 arch/x86/mm/memtest.c Tejun Heo         2011-07-12  86  		}
bfb4dc0d arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  87  	}
bfb4dc0d arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  88  }
bfb4dc0d arch/x86/mm/memtest.c Andreas Herrmann  2009-02-25  89  
1f067167 arch/x86/mm/memtest.c Yinghai Lu        2008-07-15  90  /* default is disabled */
1f067167 arch/x86/mm/memtest.c Yinghai Lu        2008-07-15  91  static int memtest_pattern __initdata;
1f067167 arch/x86/mm/memtest.c Yinghai Lu        2008-07-15  92  

:::::: The code at line 84 was first introduced by commit
:::::: bfb4dc0da45f8fddc76eba7e62919420c7d6dae2 x86: memtest: wipe out test pattern from memory

:::::: TO: Andreas Herrmann <andreas.herrmann3@amd.com>
:::::: CC: Ingo Molnar <mingo@elte.hu>

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
