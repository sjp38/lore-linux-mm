Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53B7D6B0023
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 05:06:19 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f4-v6so7294965plr.11
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 02:06:19 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 3-v6si8299993plo.475.2018.03.23.02.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 02:06:17 -0700 (PDT)
Date: Fri, 23 Mar 2018 17:06:07 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 03/10] mm: Assign memcg-aware shrinkers bitmap to memcg
Message-ID: <201803231640.37BGHC6o%fengguang.wu@intel.com>
References: <152163850081.21546.6969747084834474733.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152163850081.21546.6969747084834474733.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: kbuild-all@01.org, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

Hi Kirill,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on mmotm/master]
[also build test WARNING on v4.16-rc6 next-20180322]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Kirill-Tkhai/Improve-shrink_slab-scalability-old-complexity-was-O-n-2-new-is-O-n/20180323-052754
base:   git://git.cmpxchg.org/linux-mmotm.git master
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:79:1: sparse: incorrect type in argument 3 (different base types) @@    expected unsigned long [unsigned] flags @@    got resunsigned long [unsigned] flags @@
   include/trace/events/vmscan.h:79:1:    expected unsigned long [unsigned] flags
   include/trace/events/vmscan.h:79:1:    got restricted gfp_t [usertype] gfp_flags
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:106:1: sparse: incorrect type in argument 3 (different base types) @@    expected unsigned long [unsigned] flags @@    got resunsigned long [unsigned] flags @@
   include/trace/events/vmscan.h:106:1:    expected unsigned long [unsigned] flags
   include/trace/events/vmscan.h:106:1:    got restricted gfp_t [usertype] gfp_flags
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: cast from restricted gfp_t
   include/trace/events/vmscan.h:196:1: sparse: too many warnings
>> mm/vmscan.c:231:15: sparse: incompatible types in conditional expression (different address spaces)
>> mm/vmscan.c:231:15: sparse: cast from unknown type
>> mm/vmscan.c:231:15: sparse: incompatible types in conditional expression (different address spaces)
>> mm/vmscan.c:231:15: sparse: incompatible types in conditional expression (different address spaces)
>> mm/vmscan.c:231:15: sparse: cast from unknown type

vim +231 mm/vmscan.c

   205	
   206	static int memcg_expand_maps(struct mem_cgroup *memcg, int size, int old_size)
   207	{
   208		struct shrinkers_map *new, *old;
   209		int i;
   210	
   211		new = kvmalloc(sizeof(*new) + nr_node_ids * sizeof(new->map[0]),
   212				GFP_KERNEL);
   213		if (!new)
   214			return -ENOMEM;
   215	
   216		for (i = 0; i < nr_node_ids; i++) {
   217			new->map[i] = kvmalloc_node(size, GFP_KERNEL, i);
   218			if (!new->map[i]) {
   219				while (--i >= 0)
   220					kvfree(new->map[i]);
   221				kvfree(new);
   222				return -ENOMEM;
   223			}
   224	
   225			/* Set all old bits, clear all new bits */
   226			memset(new->map[i], (int)0xff, old_size);
   227			memset((void *)new->map[i] + old_size, 0, size - old_size);
   228		}
   229	
   230		lockdep_assert_held(&bitmap_rwsem);
 > 231		old = rcu_dereference_protected(SHRINKERS_MAP(memcg), true);
   232	
   233		/*
   234		 * We don't want to use rcu_read_lock() in shrink_slab().
   235		 * Since expansion happens rare, we may just take the lock
   236		 * here.
   237		 */
   238		if (old)
   239			down_write(&shrinker_rwsem);
   240	
   241		if (memcg)
   242			rcu_assign_pointer(memcg->shrinkers_map, new);
   243		else
   244			rcu_assign_pointer(root_shrinkers_map, new);
   245	
   246		if (old) {
   247			up_write(&shrinker_rwsem);
   248			call_rcu(&old->rcu, kvfree_map_rcu);
   249		}
   250	
   251		return 0;
   252	}
   253	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
