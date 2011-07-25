Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 368C56B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 16:52:52 -0400 (EDT)
Date: Mon, 25 Jul 2011 13:52:49 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [patch 1/5] mm: page_alloc: increase __GFP_BITS_SHIFT to include
 __GFP_OTHER_NODE
Message-ID: <20110725205249.GB21691@tassilo.jf.intel.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-2-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311625159-13771-2-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org

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

Acked-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
