Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8644B6B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:54:02 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so4575708wes.7
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 05:54:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ks8si11058591wjc.37.2014.07.18.05.53.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 05:53:57 -0700 (PDT)
Date: Fri, 18 Jul 2014 13:53:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 3/3] mm: vmscan: clean up struct scan_control
Message-ID: <20140718125349.GQ10819@suse.de>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
 <1405344049-19868-4-git-send-email-hannes@cmpxchg.org>
 <alpine.LSU.2.11.1407141240200.17669@eggly.anvils>
 <20140717132604.GF29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140717132604.GF29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 17, 2014 at 09:26:04AM -0400, Johannes Weiner wrote:
> <SNIP>
> 
> Andrew, could you please replace this patch with the following?
> 
> ---
> From bbe8c1645c77297a96ecd5d64d659ddcd6984d03 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 14 Jul 2014 08:51:54 -0400
> Subject: [patch] mm: vmscan: clean up struct scan_control
> 
> Reorder the members by input and output, then turn the individual
> integers for may_writepage, may_unmap, may_swap, compaction_ready,
> hibernation_mode into bit fields to save stack space:
> 
> +72/-296 -224
> kswapd                                       104     176     +72
> try_to_free_pages                             80      56     -24
> try_to_free_mem_cgroup_pages                  80      56     -24
> shrink_all_memory                             88      64     -24
> reclaim_clean_pages_from_list                168     144     -24
> mem_cgroup_shrink_node_zone                  104      80     -24
> __zone_reclaim                               176     152     -24
> balance_pgdat                                152       -    -152
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
