Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 263F86B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 09:51:58 -0400 (EDT)
Date: Tue, 26 Jul 2011 14:51:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/5] mm: page_alloc: increase __GFP_BITS_SHIFT to include
 __GFP_OTHER_NODE
Message-ID: <20110726135151.GB3010@suse.de>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-2-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311625159-13771-2-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Mon, Jul 25, 2011 at 10:19:15PM +0200, Johannes Weiner wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> __GFP_OTHER_NODE is used for NUMA allocations on behalf of other
> nodes.  It's supposed to be passed through from the page allocator to
> zone_statistics(), but it never gets there as gfp_allowed_mask is not
> wide enough and masks out the flag early in the allocation path.
> 
> The result is an accounting glitch where successful NUMA allocations
> by-agent are not properly attributed as local.
> 
> Increase __GFP_BITS_SHIFT so that it includes __GFP_OTHER_NODE.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

You're right, this should be merged separately.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
