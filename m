Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 896B36B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 02:40:20 -0400 (EDT)
Received: by ggm4 with SMTP id 4so7514324ggm.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 23:40:19 -0700 (PDT)
Date: Tue, 3 Jul 2012 23:40:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix vmstat and zonestat mismatch
In-Reply-To: <1341363401-19326-1-git-send-email-minchan@kernel.org>
Message-ID: <alpine.DEB.2.00.1207032339030.32556@chino.kir.corp.google.com>
References: <1341363401-19326-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, 4 Jul 2012, Minchan Kim wrote:

> e975d6ac[1] in linux-next removed NUMA_INTERLEAVE_HIT
> in zone_stat_item but didn't remove it in vmstat_text
> so that cat /proc/vmstat doesn't show right count number.

... for CONFIG_NUMA kernels.

> [1]: mm/mpol: Remove NUMA_INTERLEAVE_HIT
> 

That sha1 is going to become useless very soon.

> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: David Rientjes <rientjes@google.com>

This is for sched/numa, so it should be going to Ingo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
