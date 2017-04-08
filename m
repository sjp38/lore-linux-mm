Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 58ED76B039F
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 20:30:08 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v4so89867798pgc.20
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 17:30:08 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b4si6599067plk.305.2017.04.07.17.30.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 17:30:07 -0700 (PDT)
Date: Sat, 8 Apr 2017 08:29:49 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 133/276] include/linux/memcontrol.h:743:35: error:
 parameter 2 ('idx') has incomplete type
Message-ID: <201704080847.afTFloTD%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   5b220005fda0593464fc4549eea586e597bf783c
commit: 305552ab63f28e26d836c82e30b81899d5a919d3 [133/276] mm: memcontrol: re-use node VM page state enum
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        git checkout 305552ab63f28e26d836c82e30b81899d5a919d3
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the mmotm/master HEAD 5b220005fda0593464fc4549eea586e597bf783c builds fine.
      It only hurts bisectibility.

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/swap.h:8:0,
                    from include/linux/suspend.h:4,
                    from arch/x86/kernel/asm-offsets.c:12:
>> include/linux/memcontrol.h:743:13: warning: 'enum mem_cgroup_stat_index' declared inside parameter list will not be visible outside of this definition or declaration
           enum mem_cgroup_stat_index idx)
                ^~~~~~~~~~~~~~~~~~~~~
>> include/linux/memcontrol.h:743:35: error: parameter 2 ('idx') has incomplete type
           enum mem_cgroup_stat_index idx)
                                      ^~~
   include/linux/memcontrol.h:742:29: error: function declaration isn't a prototype [-Werror=strict-prototypes]
    static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
                                ^~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors
   make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +743 include/linux/memcontrol.h

49426420 Johannes Weiner 2013-10-16  737  static inline bool mem_cgroup_oom_synchronize(bool wait)
3812c8c8 Johannes Weiner 2013-09-12  738  {
3812c8c8 Johannes Weiner 2013-09-12  739  	return false;
3812c8c8 Johannes Weiner 2013-09-12  740  }
3812c8c8 Johannes Weiner 2013-09-12  741  
fbb9f7c4 Johannes Weiner 2017-04-07  742  static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
fbb9f7c4 Johannes Weiner 2017-04-07 @743  						 enum mem_cgroup_stat_index idx)
fbb9f7c4 Johannes Weiner 2017-04-07  744  {
fbb9f7c4 Johannes Weiner 2017-04-07  745  	return 0;
fbb9f7c4 Johannes Weiner 2017-04-07  746  }

:::::: The code at line 743 was first introduced by commit
:::::: fbb9f7c42acf2f168ca1eb86cd98dd9100155fe2 mm: vmscan: fix IO/refault regression in cache workingset transition

:::::: TO: Johannes Weiner <hannes@cmpxchg.org>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--Kj7319i9nmIyA2yE
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--Kj7319i9nmIyA2yE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
