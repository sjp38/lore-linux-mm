Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7146B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 04:19:06 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id 2so4144866igy.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:19:06 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h2si131702pab.63.2016.06.08.01.19.04
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 01:19:05 -0700 (PDT)
Date: Wed, 8 Jun 2016 17:19:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 09/10] mm: only count actual rotations as LRU reclaim cost
Message-ID: <20160608081903.GE28620@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-10-hannes@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160606194836.3624-10-hannes@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 03:48:35PM -0400, Johannes Weiner wrote:
> Noting a reference on an active file page but still deactivating it
> represents a smaller cost of reclaim than noting a referenced
> anonymous page and actually physically rotating it back to the head.
> The file page *might* refault later on, but it's definite progress
> toward freeing pages, whereas rotating the anonymous page costs us
> real time without making progress toward the reclaim goal.
> 
> Don't treat both events as equal. The following patch will hook up LRU
> balancing to cache and swap refaults, which are a much more concrete
> cost signal for reclaiming one list over the other. Remove the
> maybe-IO cost bias from page references, and only note the CPU cost
> for actual rotations that prevent the pages from getting reclaimed.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
