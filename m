Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0EE6B0031
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 14:26:12 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so2408700eek.21
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 11:26:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e2si1612404eeg.30.2013.12.16.11.26.10
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 11:26:11 -0800 (PST)
Message-ID: <52AF53BD.7060509@redhat.com>
Date: Mon, 16 Dec 2013 14:25:49 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] mm: page_alloc: Make zone distribution page aging
 policy configurable
References: <1386943807-29601-1-git-send-email-mgorman@suse.de> <1386943807-29601-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-6-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/13/2013 09:10 AM, Mel Gorman wrote:
> Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
> bug whereby new pages could be reclaimed before old pages because of
> how the page allocator and kswapd interacted on the per-zone LRU lists.
> Unfortunately it was missed during review that a consequence is that
> we also round-robin between NUMA nodes. This is bad for two reasons
> 
> 1. It alters the semantics of MPOL_LOCAL without telling anyone
> 2. It incurs an immediate remote memory performance hit in exchange
>    for a potential performance gain when memory needs to be reclaimed
>    later
> 
> No cookies for the reviewers on this one.
> 
> This patch makes the behaviour of the fair zone allocator policy
> configurable.  By default it will only distribute pages that are going
> to exist on the LRU between zones local to the allocating process. This
> preserves the historical semantics of MPOL_LOCAL.
> 
> By default, slab pages are not distributed between zones after this patch is
> applied. It can be argued that they should get similar treatment but they
> have different lifecycles to LRU pages, the shrinkers are not zone-aware
> and the interaction between the page allocator and kswapd is different
> for slabs. If it turns out to be an almost universal win, we can change
> the default.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
