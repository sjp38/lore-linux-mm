Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92C856B0318
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 03:30:03 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so106875026pfy.2
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 00:30:03 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p125si2230974pfp.119.2016.11.17.00.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 00:30:02 -0800 (PST)
Date: Thu, 17 Nov 2016 16:28:57 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [DRAFT 1/2] mm/cpuset: Exclude CDM nodes from each task's
 mems_allowed node mask
Message-ID: <201611171644.ziULN7aY%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
In-Reply-To: <1479369549-13309-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Anshuman,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.9-rc5 next-20161117]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/mm-cpuset-Exclude-CDM-nodes-from-each-task-s-mems_allowed-node-mask/20161117-160736
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   In file included from include/linux/mmzone.h:16:0,
                    from include/linux/gfp.h:5,
                    from include/linux/slab.h:14,
                    from include/linux/crypto.h:24,
                    from arch/x86/kernel/asm-offsets.c:8:
   include/linux/mm.h: In function 'system_ram':
>> include/linux/mm.h:454:61: error: 'N_COHERENT_DEVICE' undeclared (first use in this function)
     nodes_andnot(ram_nodes, node_states[N_MEMORY], node_states[N_COHERENT_DEVICE]);
                                                                ^
   include/linux/nodemask.h:176:38: note: in definition of macro 'nodes_andnot'
       __nodes_andnot(&(dst), &(src1), &(src2), MAX_NUMNODES)
                                         ^~~~
   include/linux/mm.h:454:61: note: each undeclared identifier is reported only once for each function it appears in
     nodes_andnot(ram_nodes, node_states[N_MEMORY], node_states[N_COHERENT_DEVICE]);
                                                                ^
   include/linux/nodemask.h:176:38: note: in definition of macro 'nodes_andnot'
       __nodes_andnot(&(dst), &(src1), &(src2), MAX_NUMNODES)
                                         ^~~~
   make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +/N_COHERENT_DEVICE +454 include/linux/mm.h

   448	
   449	static inline nodemask_t system_ram(void)
   450	{
   451		nodemask_t ram_nodes;
   452	
   453		nodes_clear(ram_nodes);
 > 454		nodes_andnot(ram_nodes, node_states[N_MEMORY], node_states[N_COHERENT_DEVICE]);
   455		return ram_nodes;
   456	}
   457	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--LQksG6bCIzRHxTLp
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
vwLwC82DxvprWgAA

--LQksG6bCIzRHxTLp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
