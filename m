Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B27B66B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 13:52:06 -0400 (EDT)
Message-ID: <51FBF1BA.9030801@surriel.com>
Date: Fri, 02 Aug 2013 13:51:54 -0400
From: Rik van Riel <riel@surriel.com>
MIME-Version: 1.0
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org> <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/02/2013 11:37 AM, Johannes Weiner wrote:
> Each zone that holds userspace pages of one workload must be aged at a
> speed proportional to the zone size.  Otherwise, the time an
> individual page gets to stay in memory depends on the zone it happened
> to be allocated in.  Asymmetry in the zone aging creates rather
> unpredictable aging behavior and results in the wrong pages being
> reclaimed, activated etc.


> When zone_reclaim_mode is enabled, allocations will now spread out to
> all zones on the local node, not just the first preferred zone (which
> on a 4G node might be a tiny Normal zone).
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Tested-by: Zlatko Calusic <zcalusic@bitsync.net>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
