Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB556B000A
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 07:30:04 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g1-v6so2117470edp.2
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 04:30:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b10-v6si142691edc.408.2018.07.04.04.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 04:30:03 -0700 (PDT)
Date: Wed, 4 Jul 2018 13:30:01 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [memcg:akpm/pending-review/mm 42/55] mm/memcontrol.c:4416:3:
 error: implicit declaration of function 'mem_cgroup_id_remove'; did you mean
 'mem_cgroup_under_move'?
Message-ID: <20180704113001.GK22503@dhcp22.suse.cz>
References: <201807041949.qoclZxnX%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201807041949.qoclZxnX%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, kbuild-all@01.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Please ignore this build error. I am playing with a new mm git tracking
and the patch 0day pointed at is missing memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure.patch
dependency because Andrew marked that one for review so it is in a
different branch.

On Wed 04-07-18 19:21:55, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git akpm/pending-review/mm
> head:   175738392f8ada5ba7802ff7c5521d695c86f9fd
> commit: 253239b6fd036ed9367ed582de081300e7b256d4 [42/55] mm/workingset.c: refactor workingset_init()
> config: x86_64-randconfig-x004-201826 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         git checkout 253239b6fd036ed9367ed582de081300e7b256d4
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/memcontrol.c: In function 'mem_cgroup_css_online':
> >> mm/memcontrol.c:4416:3: error: implicit declaration of function 'mem_cgroup_id_remove'; did you mean 'mem_cgroup_under_move'? [-Werror=implicit-function-declaration]
>       mem_cgroup_id_remove(memcg);
>       ^~~~~~~~~~~~~~~~~~~~
>       mem_cgroup_under_move
>    cc1: some warnings being treated as errors
> 
> vim +4416 mm/memcontrol.c
> 
> 0b8f73e1 Johannes Weiner  2016-01-20  4410  
> 73f576c0 Johannes Weiner  2016-07-20  4411  static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
> 0b8f73e1 Johannes Weiner  2016-01-20  4412  {
> 58fa2a55 Vladimir Davydov 2016-10-07  4413  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> 58fa2a55 Vladimir Davydov 2016-10-07  4414  
> cc77b3ae Kirill Tkhai     2018-07-04  4415  	if (memcg_alloc_shrinker_maps(memcg)) {
> cc77b3ae Kirill Tkhai     2018-07-04 @4416  		mem_cgroup_id_remove(memcg);
> cc77b3ae Kirill Tkhai     2018-07-04  4417  		return -ENOMEM;
> cc77b3ae Kirill Tkhai     2018-07-04  4418  	}
> cc77b3ae Kirill Tkhai     2018-07-04  4419  
> 73f576c0 Johannes Weiner  2016-07-20  4420  	/* Online state pins memcg ID, memcg ID pins CSS */
> 58fa2a55 Vladimir Davydov 2016-10-07  4421  	atomic_set(&memcg->id.ref, 1);
> 73f576c0 Johannes Weiner  2016-07-20  4422  	css_get(css);
> 2f7dd7a4 Johannes Weiner  2014-10-02  4423  	return 0;
> 8cdea7c0 Balbir Singh     2008-02-07  4424  }
> 8cdea7c0 Balbir Singh     2008-02-07  4425  
> 
> :::::: The code at line 4416 was first introduced by commit
> :::::: cc77b3ae444d49d3c2bbf7d321d51dad33f6aaef mm, memcg: assign memcg-aware shrinkers bitmap to memcg
> 
> :::::: TO: Kirill Tkhai <ktkhai@virtuozzo.com>
> :::::: CC: Michal Hocko <mhocko@suse.com>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation



-- 
Michal Hocko
SUSE Labs
