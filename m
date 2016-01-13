Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1596B0268
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:50:57 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so301381124wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 07:50:57 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id t63si39722427wmd.18.2016.01.13.07.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 07:50:56 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id l65so299071625wmf.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 07:50:56 -0800 (PST)
Date: Wed, 13 Jan 2016 16:50:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: +
 mm-oom_killc-dont-skip-pf_exiting-tasks-when-searching-for-a-victim.patch
 added to -mm tree
Message-ID: <20160113155054.GC17512@dhcp22.suse.cz>
References: <56956f40.G6t/WcHKY0Tf6XKS%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56956f40.G6t/WcHKY0Tf6XKS%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, andrea@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, riel@redhat.com, rientjes@google.com, sasha.levin@oracle.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

Thanks for having this separately. I agree with David that this is
_safer_ to route in the same series with the oom reaper but I guess the
risk to have it separare is quite low if measurable at all.

On Tue 12-01-16 13:25:20, Andrew Morton wrote:
[...]
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm/oom_kill.c: don't skip PF_EXITING tasks when searching for a victim
> 
> When the OOM killer scans tasks and encounters a PF_EXITING one, it
> force-selects that one regardless of the score. Is there a possibility
> that the task might hang after it has set PF_EXITING?  In that case the
> OOM killer should be able to move on to the next task.
>
> Frankly, I don't even know why we check for exiting tasks in the OOM
> killer.  We've tried direct reclaim at least 15 times by the time we
> decide the system is OOM, there was plenty of time to exit and free
> memory; and a task might exit voluntarily right after we issue a kill. 
> This is testing pure noise.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrea Argangeli <andrea@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  mm/oom_kill.c |    3 ---
>  1 file changed, 3 deletions(-)
> 
> diff -puN mm/oom_kill.c~mm-oom_killc-dont-skip-pf_exiting-tasks-when-searching-for-a-victim mm/oom_kill.c
> --- a/mm/oom_kill.c~mm-oom_killc-dont-skip-pf_exiting-tasks-when-searching-for-a-victim
> +++ a/mm/oom_kill.c
> @@ -292,9 +292,6 @@ enum oom_scan_t oom_scan_process_thread(
>  	if (oom_task_origin(task))
>  		return OOM_SCAN_SELECT;
>  
> -	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
> -		return OOM_SCAN_ABORT;
> -
>  	return OOM_SCAN_OK;
>  }
>  
> _
> 
> Patches currently in -mm which might be from hannes@cmpxchg.org are
> 
> mm-page_alloc-generalize-the-dirty-balance-reserve.patch
> proc-meminfo-estimate-available-memory-more-conservatively.patch
> mm-memcontrol-export-root_mem_cgroup.patch
> net-tcp_memcontrol-properly-detect-ancestor-socket-pressure.patch
> net-tcp_memcontrol-remove-bogus-hierarchy-pressure-propagation.patch
> net-tcp_memcontrol-protect-all-tcp_memcontrol-calls-by-jump-label.patch
> net-tcp_memcontrol-remove-dead-per-memcg-count-of-allocated-sockets.patch
> net-tcp_memcontrol-simplify-the-per-memcg-limit-access.patch
> net-tcp_memcontrol-sanitize-tcp-memory-accounting-callbacks.patch
> net-tcp_memcontrol-simplify-linkage-between-socket-and-page-counter.patch
> net-tcp_memcontrol-simplify-linkage-between-socket-and-page-counter-fix.patch
> mm-memcontrol-generalize-the-socket-accounting-jump-label.patch
> mm-memcontrol-do-not-account-memoryswap-on-unified-hierarchy.patch
> mm-memcontrol-move-socket-code-for-unified-hierarchy-accounting.patch
> mm-memcontrol-account-socket-memory-in-unified-hierarchy-memory-controller.patch
> mm-memcontrol-hook-up-vmpressure-to-socket-pressure.patch
> mm-memcontrol-switch-to-the-updated-jump-label-api.patch
> mm-oom_killc-dont-skip-pf_exiting-tasks-when-searching-for-a-victim.patch
> mm-memcontrol-drop-unused-css-argument-in-memcg_init_kmem.patch
> mm-memcontrol-remove-double-kmem-page_counter-init.patch
> mm-memcontrol-give-the-kmem-states-more-descriptive-names.patch
> mm-memcontrol-group-kmem-init-and-exit-functions-together.patch
> mm-memcontrol-separate-kmem-code-from-legacy-tcp-accounting-code.patch
> mm-memcontrol-move-kmem-accounting-code-to-config_memcg.patch
> mm-memcontrol-move-kmem-accounting-code-to-config_memcg-v2.patch
> mm-memcontrol-move-kmem-accounting-code-to-config_memcg-fix.patch
> mm-memcontrol-account-kmem-consumers-in-cgroup2-memory-controller.patch
> mm-memcontrol-introduce-config_memcg_legacy_kmem.patch
> mm-memcontrol-reign-in-the-config-space-madness.patch
> mm-memcontrol-flatten-struct-cg_proto.patch
> mm-memcontrol-clean-up-alloc-online-offline-free-functions.patch
> mm-memcontrol-clean-up-alloc-online-offline-free-functions-fix.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
