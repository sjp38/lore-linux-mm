Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 993206B0253
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 22:18:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r6so7948092pfj.14
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:18:45 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n9si5542365plp.715.2017.10.19.19.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 19:18:44 -0700 (PDT)
Date: Fri, 20 Oct 2017 10:17:45 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 171/244] lib/bug.c:212:2: note: in expansion of macro
 'list_for_each_entry_rcu'
Message-ID: <201710201043.iwyiQblt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   8c953f23aaffa1931eb463adbe10f0303ef977b1
commit: 180723ec144b81ffbe3730d20212ce5f921fe319 [171/244] kernel debug: support resetting WARN_ONCE for all architectures
config: i386-alldefconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        git checkout 180723ec144b81ffbe3730d20212ce5f921fe319
        # save the attached .config to linux build tree
        make ARCH=i386 

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/list.h:8:0,
                    from lib/bug.c:43:
   lib/bug.c: In function 'generic_bug_clear_once':
   lib/bug.c:212:32: error: 'module_bug_list' undeclared (first use in this function)
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
                                   ^
   include/linux/kernel.h:927:26: note: in definition of macro 'container_of'
     void *__mptr = (void *)(ptr);     \
                             ^~~
>> include/linux/rculist.h:277:15: note: in expansion of macro 'lockless_dereference'
     container_of(lockless_dereference(ptr), type, member)
                  ^~~~~~~~~~~~~~~~~~~~
>> include/linux/rculist.h:351:13: note: in expansion of macro 'list_entry_rcu'
     for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
                ^~~~~~~~~~~~~~
>> lib/bug.c:212:2: note: in expansion of macro 'list_for_each_entry_rcu'
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
     ^~~~~~~~~~~~~~~~~~~~~~~
   lib/bug.c:212:32: note: each undeclared identifier is reported only once for each function it appears in
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
                                   ^
   include/linux/kernel.h:927:26: note: in definition of macro 'container_of'
     void *__mptr = (void *)(ptr);     \
                             ^~~
>> include/linux/rculist.h:277:15: note: in expansion of macro 'lockless_dereference'
     container_of(lockless_dereference(ptr), type, member)
                  ^~~~~~~~~~~~~~~~~~~~
>> include/linux/rculist.h:351:13: note: in expansion of macro 'list_entry_rcu'
     for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
                ^~~~~~~~~~~~~~
>> lib/bug.c:212:2: note: in expansion of macro 'list_for_each_entry_rcu'
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
     ^~~~~~~~~~~~~~~~~~~~~~~
   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/linux/list.h:4,
                    from lib/bug.c:43:
   include/linux/kernel.h:928:32: error: invalid type argument of unary '*' (have 'int')
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                                   ^~~~~~
   include/linux/compiler.h:553:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:576:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:46:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/rculist.h:277:2: note: in expansion of macro 'container_of'
     container_of(lockless_dereference(ptr), type, member)
     ^~~~~~~~~~~~
>> include/linux/rculist.h:351:13: note: in expansion of macro 'list_entry_rcu'
     for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
                ^~~~~~~~~~~~~~
>> lib/bug.c:212:2: note: in expansion of macro 'list_for_each_entry_rcu'
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
     ^~~~~~~~~~~~~~~~~~~~~~~
>> include/linux/rculist.h:351:49: error: dereferencing pointer to incomplete type 'struct module'
     for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
                                                     
   include/linux/compiler.h:553:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:576:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:46:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/rculist.h:277:2: note: in expansion of macro 'container_of'
     container_of(lockless_dereference(ptr), type, member)
     ^~~~~~~~~~~~
>> include/linux/rculist.h:351:13: note: in expansion of macro 'list_entry_rcu'
     for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
                ^~~~~~~~~~~~~~
>> lib/bug.c:212:2: note: in expansion of macro 'list_for_each_entry_rcu'
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
     ^~~~~~~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:929:18: error: invalid type argument of unary '*' (have 'int')
        !__same_type(*(ptr), void),   \
                     ^~~~~~
   include/linux/compiler.h:553:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:576:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:46:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:929:6: note: in expansion of macro '__same_type'
        !__same_type(*(ptr), void),   \
         ^~~~~~~~~~~
   include/linux/rculist.h:277:2: note: in expansion of macro 'container_of'
     container_of(lockless_dereference(ptr), type, member)
     ^~~~~~~~~~~~
>> include/linux/rculist.h:351:13: note: in expansion of macro 'list_entry_rcu'
     for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
                ^~~~~~~~~~~~~~
>> lib/bug.c:212:2: note: in expansion of macro 'list_for_each_entry_rcu'
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
     ^~~~~~~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:32: error: invalid type argument of unary '*' (have 'int')
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                                   ^~~~~~
   include/linux/compiler.h:553:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:576:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:46:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:20: note: in expansion of macro '__same_type'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
                       ^~~~~~~~~~~
   include/linux/rculist.h:277:2: note: in expansion of macro 'container_of'
     container_of(lockless_dereference(ptr), type, member)
     ^~~~~~~~~~~~
   include/linux/rculist.h:353:9: note: in expansion of macro 'list_entry_rcu'
      pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
            ^~~~~~~~~~~~~~
>> lib/bug.c:212:2: note: in expansion of macro 'list_for_each_entry_rcu'
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
     ^~~~~~~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:929:18: error: invalid type argument of unary '*' (have 'int')
        !__same_type(*(ptr), void),   \
                     ^~~~~~
   include/linux/compiler.h:553:19: note: in definition of macro '__compiletime_assert'
      bool __cond = !(condition);    \
                      ^~~~~~~~~
   include/linux/compiler.h:576:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/build_bug.h:46:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:928:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
     ^~~~~~~~~~~~~~~~
   include/linux/kernel.h:929:6: note: in expansion of macro '__same_type'
        !__same_type(*(ptr), void),   \
         ^~~~~~~~~~~
   include/linux/rculist.h:277:2: note: in expansion of macro 'container_of'
     container_of(lockless_dereference(ptr), type, member)
     ^~~~~~~~~~~~
   include/linux/rculist.h:353:9: note: in expansion of macro 'list_entry_rcu'
      pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
            ^~~~~~~~~~~~~~
>> lib/bug.c:212:2: note: in expansion of macro 'list_for_each_entry_rcu'
     list_for_each_entry_rcu(mod, &module_bug_list, bug_list)
     ^~~~~~~~~~~~~~~~~~~~~~~

vim +/list_for_each_entry_rcu +212 lib/bug.c

   206	
   207	void generic_bug_clear_once(void)
   208	{
   209		struct module *mod;
   210	
   211		rcu_read_lock_sched();
 > 212		list_for_each_entry_rcu(mod, &module_bug_list, bug_list)

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--45Z9DzgjV8m4Oswq
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AA==

--45Z9DzgjV8m4Oswq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
