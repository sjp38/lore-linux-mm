Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A0AE06B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 23:10:26 -0500 (EST)
Message-ID: <4EEAC4AC.90600@redhat.com>
Date: Thu, 15 Dec 2011 23:10:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/11] mm: page allocator: Do not call direct reclaim
 for THP allocations while compaction is deferred
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/14/2011 10:41 AM, Mel Gorman wrote:
> If compaction is deferred, direct reclaim is used to try free enough
> pages for the allocation to succeed. For small high-orders, this has
> a reasonable chance of success. However, if the caller has specified
> __GFP_NO_KSWAPD to limit the disruption to the system, it makes more
> sense to fail the allocation rather than stall the caller in direct
> reclaim. This patch skips direct reclaim if compaction is deferred
> and the caller specifies __GFP_NO_KSWAPD.
>
> Async compaction only considers a subset of pages so it is possible for
> compaction to be deferred prematurely and not enter direct reclaim even
> in cases where it should. To compensate for this, this patch also defers
> compaction only if sync compaction failed.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>
> Acked-by: Minchan Kim<minchan.kim@gmail.com>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
