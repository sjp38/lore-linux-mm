Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 783296B7B09
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 18:22:09 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e124-v6so6066846pgc.11
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 15:22:09 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x5-v6si5807946plv.304.2018.09.06.15.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 15:22:07 -0700 (PDT)
Date: Fri, 7 Sep 2018 06:21:43 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2] mm: slowly shrink slabs with a relatively small
 number of objects
Message-ID: <201809070616.4yBTU0cs%fengguang.wu@intel.com>
References: <20180904224707.10356-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180904224707.10356-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Rik van Riel <riel@surriel.com>, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Roman,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.19-rc2 next-20180906]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Roman-Gushchin/mm-slowly-shrink-slabs-with-a-relatively-small-number-of-objects/20180906-142351
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
   include/trace/events/vmscan.h:196:1: sparse: too many warnings
>> mm/vmscan.c:488:17: sparse: incompatible types in comparison expression (different type sizes)
   In file included from include/asm-generic/bug.h:18:0,
                    from arch/x86/include/asm/bug.h:83,
                    from include/linux/bug.h:5,
                    from include/linux/mmdebug.h:5,
                    from include/linux/mm.h:9,
                    from mm/vmscan.c:17:
   mm/vmscan.c: In function 'do_shrink_slab':
   include/linux/kernel.h:845:29: warning: comparison of distinct pointer types lacks a cast
      (!!(sizeof((typeof(x) *)1 == (typeof(y) *)1)))
                                ^
   include/linux/kernel.h:859:4: note: in expansion of macro '__typecheck'
      (__typecheck(x, y) && __no_side_effects(x, y))
       ^~~~~~~~~~~
   include/linux/kernel.h:869:24: note: in expansion of macro '__safe_cmp'
     __builtin_choose_expr(__safe_cmp(x, y), 121-                        ^~~~~~~~~~
   include/linux/kernel.h:885:19: note: in expansion of macro '__careful_cmp'
    #define max(x, y) __careful_cmp(x, y, >)
                      ^~~~~~~~~~~~~
   mm/vmscan.c:488:10: note: in expansion of macro 'max'
     delta = max(delta, min(freeable, batch_size));
             ^~~

vim +488 mm/vmscan.c

   446	
   447	static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
   448					    struct shrinker *shrinker, int priority)
   449	{
   450		unsigned long freed = 0;
   451		unsigned long long delta;
   452		long total_scan;
   453		long freeable;
   454		long nr;
   455		long new_nr;
   456		int nid = shrinkctl->nid;
   457		long batch_size = shrinker->batch ? shrinker->batch
   458						  : SHRINK_BATCH;
   459		long scanned = 0, next_deferred;
   460	
   461		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
   462			nid = 0;
   463	
   464		freeable = shrinker->count_objects(shrinker, shrinkctl);
   465		if (freeable == 0 || freeable == SHRINK_EMPTY)
   466			return freeable;
   467	
   468		/*
   469		 * copy the current shrinker scan count into a local variable
   470		 * and zero it so that other concurrent shrinker invocations
   471		 * don't also do this scanning work.
   472		 */
   473		nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
   474	
   475		total_scan = nr;
   476		delta = freeable >> priority;
   477		delta *= 4;
   478		do_div(delta, shrinker->seeks);
   479	
   480		/*
   481		 * Make sure we apply some minimal pressure even on
   482		 * small cgroups. This is necessary because some of
   483		 * belonging objects can hold a reference to a dying
   484		 * child cgroup. If we don't scan them, the dying
   485		 * cgroup can't go away unless the memory pressure
   486		 * (and the scanning priority) raise significantly.
   487		 */
 > 488		delta = max(delta, min(freeable, batch_size));
   489	
   490		total_scan += delta;
   491		if (total_scan < 0) {
   492			pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
   493			       shrinker->scan_objects, total_scan);
   494			total_scan = freeable;
   495			next_deferred = nr;
   496		} else
   497			next_deferred = total_scan;
   498	
   499		/*
   500		 * We need to avoid excessive windup on filesystem shrinkers
   501		 * due to large numbers of GFP_NOFS allocations causing the
   502		 * shrinkers to return -1 all the time. This results in a large
   503		 * nr being built up so when a shrink that can do some work
   504		 * comes along it empties the entire cache due to nr >>>
   505		 * freeable. This is bad for sustaining a working set in
   506		 * memory.
   507		 *
   508		 * Hence only allow the shrinker to scan the entire cache when
   509		 * a large delta change is calculated directly.
   510		 */
   511		if (delta < freeable / 4)
   512			total_scan = min(total_scan, freeable / 2);
   513	
   514		/*
   515		 * Avoid risking looping forever due to too large nr value:
   516		 * never try to free more than twice the estimate number of
   517		 * freeable entries.
   518		 */
   519		if (total_scan > freeable * 2)
   520			total_scan = freeable * 2;
   521	
   522		trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
   523					   freeable, delta, total_scan, priority);
   524	
   525		/*
   526		 * Normally, we should not scan less than batch_size objects in one
   527		 * pass to avoid too frequent shrinker calls, but if the slab has less
   528		 * than batch_size objects in total and we are really tight on memory,
   529		 * we will try to reclaim all available objects, otherwise we can end
   530		 * up failing allocations although there are plenty of reclaimable
   531		 * objects spread over several slabs with usage less than the
   532		 * batch_size.
   533		 *
   534		 * We detect the "tight on memory" situations by looking at the total
   535		 * number of objects we want to scan (total_scan). If it is greater
   536		 * than the total number of objects on slab (freeable), we must be
   537		 * scanning at high prio and therefore should try to reclaim as much as
   538		 * possible.
   539		 */
   540		while (total_scan >= batch_size ||
   541		       total_scan >= freeable) {
   542			unsigned long ret;
   543			unsigned long nr_to_scan = min(batch_size, total_scan);
   544	
   545			shrinkctl->nr_to_scan = nr_to_scan;
   546			shrinkctl->nr_scanned = nr_to_scan;
   547			ret = shrinker->scan_objects(shrinker, shrinkctl);
   548			if (ret == SHRINK_STOP)
   549				break;
   550			freed += ret;
   551	
   552			count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
   553			total_scan -= shrinkctl->nr_scanned;
   554			scanned += shrinkctl->nr_scanned;
   555	
   556			cond_resched();
   557		}
   558	
   559		if (next_deferred >= scanned)
   560			next_deferred -= scanned;
   561		else
   562			next_deferred = 0;
   563		/*
   564		 * move the unused scan count back into the shrinker in a
   565		 * manner that handles concurrent updates. If we exhausted the
   566		 * scan, there is no need to do an update.
   567		 */
   568		if (next_deferred > 0)
   569			new_nr = atomic_long_add_return(next_deferred,
   570							&shrinker->nr_deferred[nid]);
   571		else
   572			new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
   573	
   574		trace_mm_shrink_slab_end(shrinker, nid, freed, nr, new_nr, total_scan);
   575		return freed;
   576	}
   577	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
