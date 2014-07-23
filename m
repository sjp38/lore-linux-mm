Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B6A8D6B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 21:02:13 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so557009pdb.38
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 18:02:13 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id m8si345904pdk.128.2014.07.22.18.02.12
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 18:02:12 -0700 (PDT)
Date: Wed, 23 Jul 2014 09:02:07 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 154/499] mm/memcontrol.c:2957:17: sparse: incorrect type in assignment (different address spaces)
Message-ID: <53cf098f.6erIwAzrTaos8Miy%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   bb46fa8ad844d29e9f74f6209777d955a42916f6
commit: 1112ca072bdf33b4e2affa3e4087048333343a08 [154/499] memcg: add pointer to owner cache to memcg_cache_params
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/memcontrol.c:2957:17: sparse: incorrect type in assignment (different address spaces)
   mm/memcontrol.c:2957:17:    expected struct memcg_cache_params *volatile <noident>
   mm/memcontrol.c:2957:17:    got struct memcg_cache_params [noderef] <asn:4>*<noident>
   mm/slab.h:162:18: sparse: incompatible types in comparison expression (different address spaces)
   mm/slab.h:162:18: sparse: incompatible types in comparison expression (different address spaces)
   mm/slab.h:162:18: sparse: incompatible types in comparison expression (different address spaces)
   mm/slab.h:162:18: sparse: incompatible types in comparison expression (different address spaces)
   mm/memcontrol.c:4575:21: sparse: incompatible types in comparison expression (different address spaces)
   mm/memcontrol.c:4577:21: sparse: incompatible types in comparison expression (different address spaces)
   mm/memcontrol.c:6014:31: sparse: incompatible types in comparison expression (different address spaces)

vim +2957 mm/memcontrol.c

55007d84 Glauber Costa    2012-12-18  2941  		for (i = 0; i < memcg_limited_groups_array_size; i++) {
55007d84 Glauber Costa    2012-12-18  2942  			if (!cur_params->memcg_caches[i])
55007d84 Glauber Costa    2012-12-18  2943  				continue;
f8570263 Vladimir Davydov 2014-01-23  2944  			new_params->memcg_caches[i] =
55007d84 Glauber Costa    2012-12-18  2945  						cur_params->memcg_caches[i];
55007d84 Glauber Costa    2012-12-18  2946  		}
55007d84 Glauber Costa    2012-12-18  2947  
55007d84 Glauber Costa    2012-12-18  2948  		/*
55007d84 Glauber Costa    2012-12-18  2949  		 * Ideally, we would wait until all caches succeed, and only
55007d84 Glauber Costa    2012-12-18  2950  		 * then free the old one. But this is not worth the extra
55007d84 Glauber Costa    2012-12-18  2951  		 * pointer per-cache we'd have to have for this.
55007d84 Glauber Costa    2012-12-18  2952  		 *
55007d84 Glauber Costa    2012-12-18  2953  		 * It is not a big deal if some caches are left with a size
55007d84 Glauber Costa    2012-12-18  2954  		 * bigger than the others. And all updates will reset this
55007d84 Glauber Costa    2012-12-18  2955  		 * anyway.
55007d84 Glauber Costa    2012-12-18  2956  		 */
f8570263 Vladimir Davydov 2014-01-23 @2957  		rcu_assign_pointer(s->memcg_params, new_params);
f8570263 Vladimir Davydov 2014-01-23  2958  		if (cur_params)
f8570263 Vladimir Davydov 2014-01-23  2959  			kfree_rcu(cur_params, rcu_head);
55007d84 Glauber Costa    2012-12-18  2960  	}
55007d84 Glauber Costa    2012-12-18  2961  	return 0;
55007d84 Glauber Costa    2012-12-18  2962  }
55007d84 Glauber Costa    2012-12-18  2963  
363a044f Vladimir Davydov 2014-01-23  2964  int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
363a044f Vladimir Davydov 2014-01-23  2965  			     struct kmem_cache *root_cache)

:::::: The code at line 2957 was first introduced by commit
:::::: f8570263ee16eb1d5038b8e20d7db3a68bbb2b49 memcg, slab: RCU protect memcg_params for root caches

:::::: TO: Vladimir Davydov <vdavydov@parallels.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
