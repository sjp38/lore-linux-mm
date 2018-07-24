Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 885FD6B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:44:05 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e19-v6so2685147pgv.11
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:44:05 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r6-v6si11821034pgm.647.2018.07.24.07.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 07:44:04 -0700 (PDT)
Date: Tue, 24 Jul 2018 22:43:20 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [linux-next:master 7986/8610] mm/vmacache.c:14:39: error:
 'PMD_SHIFT' undeclared; did you mean 'NMI_SHIFT'?
Message-ID: <201807242217.aUOXI16w%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   3946cd385042069ec57d3f04240def53b4eed7e5
commit: 5d2f33872046e7ffdd62dd80472cd466ea8407ac [7986/8610] mm, vmacache: hash addresses based on pmd
config: microblaze-nommu_defconfig (attached as .config)
compiler: microblaze-linux-gcc (GCC) 8.1.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 5d2f33872046e7ffdd62dd80472cd466ea8407ac
        # save the attached .config to linux build tree
        GCC_VERSION=8.1.0 make.cross ARCH=microblaze 

Note: the linux-next/master HEAD 3946cd385042069ec57d3f04240def53b4eed7e5 builds fine.
      It may have been fixed somewhere.

All errors (new ones prefixed by >>):

   mm/vmacache.c: In function 'vmacache_update':
>> mm/vmacache.c:14:39: error: 'PMD_SHIFT' undeclared (first use in this function); did you mean 'NMI_SHIFT'?
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                          ^~~~~~~~~
   mm/vmacache.c:71:26: note: in expansion of macro 'VMACACHE_HASH'
      current->vmacache.vmas[VMACACHE_HASH(addr)] = newvma;
                             ^~~~~~~~~~~~~
   mm/vmacache.c:14:39: note: each undeclared identifier is reported only once for each function it appears in
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                          ^~~~~~~~~
   mm/vmacache.c:71:26: note: in expansion of macro 'VMACACHE_HASH'
      current->vmacache.vmas[VMACACHE_HASH(addr)] = newvma;
                             ^~~~~~~~~~~~~
   mm/vmacache.c: In function 'vmacache_find':
>> mm/vmacache.c:14:39: error: 'PMD_SHIFT' undeclared (first use in this function); did you mean 'NMI_SHIFT'?
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                          ^~~~~~~~~
   mm/vmacache.c:96:12: note: in expansion of macro 'VMACACHE_HASH'
     int idx = VMACACHE_HASH(addr);
               ^~~~~~~~~~~~~
   mm/vmacache.c: In function 'vmacache_find_exact':
   mm/vmacache.c:127:26: error: 'addr' undeclared (first use in this function)
     int idx = VMACACHE_HASH(addr);
                             ^~~~
   mm/vmacache.c:14:31: note: in definition of macro 'VMACACHE_HASH'
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                  ^~~~
>> mm/vmacache.c:14:39: error: 'PMD_SHIFT' undeclared (first use in this function); did you mean 'NMI_SHIFT'?
    #define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
                                          ^~~~~~~~~
   mm/vmacache.c:127:12: note: in expansion of macro 'VMACACHE_HASH'
     int idx = VMACACHE_HASH(addr);
               ^~~~~~~~~~~~~

vim +14 mm/vmacache.c

     9	
    10	/*
    11	 * Hash based on the pmd of addr.  Provides a good hit rate for workloads with
    12	 * spatial locality.
    13	 */
  > 14	#define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
    15	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--rwEMma7ioTxnRzrJ
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--rwEMma7ioTxnRzrJ--
