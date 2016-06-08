Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 639756B025F
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 04:15:54 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id i11so4143186igh.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:15:54 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 190si675626iof.172.2016.06.08.01.15.53
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 01:15:53 -0700 (PDT)
Date: Wed, 8 Jun 2016 17:15:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 08/10] mm: deactivations shouldn't bias the LRU balance
Message-ID: <20160608081515.GD28620@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-9-hannes@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160606194836.3624-9-hannes@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 03:48:34PM -0400, Johannes Weiner wrote:
> Operations like MADV_FREE, FADV_DONTNEED etc. currently move any
> affected active pages to the inactive list to accelerate their reclaim
> (good) but also steer page reclaim toward that LRU type, or away from
> the other (bad).
> 
> The reason why this is undesirable is that such operations are not
> part of the regular page aging cycle, and rather a fluke that doesn't
> say much about the remaining pages on that list. They might all be in
> heavy use. But once the chunk of easy victims has been purged, the VM
> continues to apply elevated pressure on the remaining hot pages. The
> other LRU, meanwhile, might have easily reclaimable pages, and there
> was never a need to steer away from it in the first place.
> 
> As the previous patch outlined, we should focus on recording actually
> observed cost to steer the balance rather than speculating about the
> potential value of one LRU list over the other. In that spirit, leave
> explicitely deactivated pages to the LRU algorithm to pick up, and let
> rotations decide which list is the easiest to reclaim.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Nice description. Agreed.

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
