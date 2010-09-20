Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5B56B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 07:18:59 -0400 (EDT)
Date: Mon, 20 Sep 2010 12:18:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/10] hugetlb: redefine hugepage copy functions
Message-ID: <20100920111844.GL1998@csn.ul.ie>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-4-git-send-email-n-horiguchi@ah.jp.nec.com> <20100920110323.GI1998@csn.ul.ie> <215a2d3717d0d55026688fb59ff7bb79.squirrel@www.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <215a2d3717d0d55026688fb59ff7bb79.squirrel@www.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 20, 2010 at 01:15:44PM +0200, Andi Kleen wrote:
> 
> >> +static void copy_gigantic_page(struct page *dst, struct page *src)
> >> +{
> >> +	int i;
> >> +	struct hstate *h = page_hstate(src);
> >> +	struct page *dst_base = dst;
> >> +	struct page *src_base = src;
> >> +
> >> +	for (i = 0; i < pages_per_huge_page(h); ) {
> >> +		cond_resched();
> >
> > Should this function not have a might_sleep() check too?
> 
> cond_resched() implies might_sleep I believe. I think
> that answers the earlier question too becuse that function
> calls this.
> 

You're right, cond_resched() calls might_sleep so the additional check
is redundant.

> 	/*
> >
> > Other than the removal of the might_sleep() check, this looks ok too.
> 
> Can I assume an Ack?
> 

Yes.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
