Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E804B6B0078
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 10:45:20 -0500 (EST)
Date: Tue, 23 Feb 2010 16:45:12 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] vmscan: detect mapped file pages used only once
Message-ID: <20100223154512.GD29762@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org> <1266868150-25984-4-git-send-email-hannes@cmpxchg.org> <1266937393.2723.46.camel@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1266937393.2723.46.camel@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Feb 24, 2010 at 12:03:13AM +0900, Minchan Kim wrote:
> On Mon, 2010-02-22 at 20:49 +0100, Johannes Weiner wrote:
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 278cd27..5a48bda 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -511,9 +511,6 @@ int page_referenced(struct page *page,
> >  	int referenced = 0;
> >  	int we_locked = 0;
> >  
> > -	if (TestClearPageReferenced(page))
> > -		referenced++;
> > -
> 
> >From now on, page_referenced see only page table for reference. 
> So let's comment it on function description.
> like "This function checks reference from only pte"

Hehe, the function comment already says:

	* returns the number of ptes which referenced the page.

so it is already correct.  Only the code did not match it until now.

> It looks good to me except PAGEREF_RECLAIM_CLEAN. 
> 
> I am glad to meet your this effort, again, Hannes. :)

Thank you for your review,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
