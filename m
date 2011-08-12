Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 08AEE6B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 11:27:41 -0400 (EDT)
Message-ID: <4E454656.9010608@redhat.com>
Date: Fri, 12 Aug 2011 11:27:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] mm: vmscan: Immediately reclaim end-of-LRU dirty
 pages when writeback completes
References: <1312973240-32576-1-git-send-email-mgorman@suse.de> <1312973240-32576-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1312973240-32576-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Minchan Kim <minchan.kim@gmail.com>

On 08/10/2011 06:47 AM, Mel Gorman wrote:
> When direct reclaim encounters a dirty page, it gets recycled around
> the LRU for another cycle. This patch marks the page PageReclaim
> similar to deactivate_page() so that the page gets reclaimed almost
> immediately after the page gets cleaned. This is to avoid reclaiming
> clean pages that are younger than a dirty page encountered at the
> end of the LRU that might have been something like a use-once page.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>
> Acked-by: Johannes Weiner<jweiner@redhat.com>

I'm thinking we may need to add some code to
ClearPageReclaim to mark_page_accessed, but
that would be completely independent of these
patches, so ...

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
