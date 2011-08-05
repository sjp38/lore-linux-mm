Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 07B3A6B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 10:16:48 -0400 (EDT)
Message-ID: <4E3BFB3D.1050405@redhat.com>
Date: Fri, 05 Aug 2011 10:16:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/5] mm: page_alloc: increase __GFP_BITS_SHIFT to include
 __GFP_OTHER_NODE
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com> <1311625159-13771-2-git-send-email-jweiner@redhat.com>
In-Reply-To: <1311625159-13771-2-git-send-email-jweiner@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On 07/25/2011 04:19 PM, Johannes Weiner wrote:
> From: Johannes Weiner<hannes@cmpxchg.org>
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
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
