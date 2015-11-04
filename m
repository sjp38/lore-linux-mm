Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 881C86B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 04:18:07 -0500 (EST)
Received: by wmeg8 with SMTP id g8so35942102wme.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 01:18:07 -0800 (PST)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id 79si2306324wmu.55.2015.11.04.01.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 01:18:06 -0800 (PST)
Received: by wicll6 with SMTP id ll6so85662120wic.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 01:18:06 -0800 (PST)
Date: Wed, 4 Nov 2015 10:18:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + memcg-fix-thresholds-for-32b-architectures-fix-fix.patch added
 to -mm tree
Message-ID: <20151104091804.GE29607@dhcp22.suse.cz>
References: <563943fb.IYtEMWL7tCGWBkSl%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563943fb.IYtEMWL7tCGWBkSl%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ben@decadent.org.uk, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue 03-11-15 15:32:11, Andrew Morton wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: memcg-fix-thresholds-for-32b-architectures-fix-fix
> 
> don't attempt to inline mem_cgroup_usage()
> 
> The compiler ignores the inline anwyay.  And __always_inlining it adds 600
> bytes of goop to the .o file.

I am not sure you whether you want to fold this into the original patch
but I would prefer this to be a separate one. Anyway it makes a good
sense. The only performance semi-sensitive path would be
__mem_cgroup_threshold but I seriously doubt a single function call
would make a measurable difference because memcg_check_events is rate
limited.

> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
> 
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN mm/memcontrol.c~memcg-fix-thresholds-for-32b-architectures-fix-fix mm/memcontrol.c
> --- a/mm/memcontrol.c~memcg-fix-thresholds-for-32b-architectures-fix-fix
> +++ a/mm/memcontrol.c
> @@ -2801,7 +2801,7 @@ static unsigned long tree_stat(struct me
>  	return val;
>  }
>  
> -static inline unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
> +static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  {
>  	unsigned long val;
>  
> _
> 
> Patches currently in -mm which might be from akpm@linux-foundation.org are
> 
> arch-alpha-kernel-systblss-remove-debug-check.patch
> drivers-gpu-drm-i915-intel_spritec-fix-build.patch
> drivers-gpu-drm-i915-intel_tvc-fix-build.patch
> mm.patch
> slub-optimize-bulk-slowpath-free-by-detached-freelist-fix.patch
> uaccess-reimplement-probe_kernel_address-using-probe_kernel_read.patch
> uaccess-reimplement-probe_kernel_address-using-probe_kernel_read-fix.patch
> uaccess-reimplement-probe_kernel_address-using-probe_kernel_read-fix-fix.patch
> mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-fix.patch
> mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-checkpatch-fixes.patch
> mm-page_alloc-only-enforce-watermarks-for-order-0-allocations-fix-fix.patch
> mm-fix-declarations-of-nr-delta-and-nr_pagecache_reclaimable-fix.patch
> mm-oom_kill-fix-the-wrong-task-mm-==-mm-checks-in-oom_kill_process-fix.patch
> include-linux-mmzoneh-reflow-comment.patch
> mm-fs-introduce-mapping_gfp_constraint-checkpatch-fixes.patch
> mm-vmstatc-uninline-node_page_state.patch
> mm-vmstatc-uninline-node_page_state-fix.patch
> mm-cmac-suppress-warning.patch
> memcg-fix-thresholds-for-32b-architectures-fix-fix.patch
> kasan-various-fixes-in-documentation-checkpatch-fixes.patch
> mm-slub-kasan-enable-user-tracking-by-default-with-kasan=y-fix.patch
> zsmalloc-add-comments-for-inuse-to-zspage-v2-fix.patch
> page-flags-define-pg_locked-behavior-on-compound-pages-fix.patch
> mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix.patch
> mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-checkpatch-fixes.patch
> mm-increase-swap_cluster_max-to-batch-tlb-flushes-fix-fix.patch
> include-linux-compiler-gcch-improve-__visible-documentation.patch
> fs-jffs2-wbufc-remove-stray-semicolon.patch
> lib-documentation-synchronize-%p-formatting-documentation-fix-fix.patch
> rbtree-clarify-documentation-of-rbtree_postorder_for_each_entry_safe-fix.patch
> dma-mapping-tidy-up-dma_parms-default-handling-fix.patch
> panic-release-stale-console-lock-to-always-get-the-logbuf-printed-out-fix.patch
> linux-next-rejects.patch
> mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-nvem-fix.patch
> mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-arm-fix.patch
> mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-arm-fix-fix.patch
> net-ipv4-routec-prevent-oops.patch
> remove-abs64.patch
> remove-abs64-fix.patch
> remove-abs64-fix-fix.patch
> remove-abs64-fix-fix-fix.patch
> do_shared_fault-check-that-mmap_sem-is-held.patch
> kernel-forkc-export-kernel_thread-to-modules.patch
> slab-leaks3-default-y.patch

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
