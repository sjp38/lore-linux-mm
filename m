Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C62C16B005D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 04:26:07 -0400 (EDT)
Date: Wed, 8 Aug 2012 17:27:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/6] mm: vmscan: Scale number of pages reclaimed by
 reclaim/compaction based on failures
Message-ID: <20120808082738.GF4247@bbox>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-3-git-send-email-mgorman@suse.de>
 <20120808014824.GB4247@bbox>
 <20120808075526.GI29814@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120808075526.GI29814@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 08, 2012 at 08:55:26AM +0100, Mel Gorman wrote:
> On Wed, Aug 08, 2012 at 10:48:24AM +0900, Minchan Kim wrote:
> > Hi Mel,
> > 
> > Just out of curiosity.
> > What's the problem did you see? (ie, What's the problem do this patch solve?)
> 
> Everythign in this series is related to the problem in the leader - high
> order allocation success rates are lower. This patch increases the success
> rates when allocating under load.
> 
> > AFAIUC, it seem to solve consecutive allocation success ratio through
> > getting several free pageblocks all at once in a process/kswapd
> > reclaim context. Right?
> 
> Only pageblocks if it is order-9 on x86, it reclaims an amount that depends
> on an allocation size. This only happens during reclaim/compaction context
> when we know that a high-order allocation has recently failed. The objective
> is to reclaim enough order-0 pages so that compaction can succeed again.

Your patch increases the number of pages to be reclaimed with considering
the number of fail case during deferring period and your test proved it's
really good. Without your patch, why can't VM reclaim enough pages?
Other processes steal the pages reclaimed?
Why I ask a question is that I want to know what's the problem at current
VM.


> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
