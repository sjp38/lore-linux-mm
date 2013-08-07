Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2DFF06B00E3
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 11:13:08 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:13:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/9] mm: zone_reclaim: remove ZONE_RECLAIM_LOCKED
Message-ID: <20130807151303.GR2296@suse.de>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1375459596-30061-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:28PM +0200, Andrea Arcangeli wrote:
> Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
> thread allocates memory at the same time, it forces a premature
> allocation into remote NUMA nodes even when there's plenty of clean
> cache to reclaim in the local nodes.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I would have preferred if the changelog included the history of why this
exists at all (prevents excessive reclaim from parallel allocation requests)
and why it should not currently be a problem (SWAP_CLUSTER_MAX should
be strictly obeyed limiting the excessive reclaim to SWAP_CLUSTER_MAX *
nr_parallel_requests). Hopefully we'll remember to connect any bugs about
excessive reclaim + zone_reclaim to this patch :)

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
