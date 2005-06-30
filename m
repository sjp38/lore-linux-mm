Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5UJLOOM405230
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 15:21:24 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5UJLNcC181896
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 13:21:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5UJLNTJ029784
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 13:21:23 -0600
Subject: Re: [ckrm-tech] [PATCH 4/6] CKRM: Add guarantee support for mem
	controller
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
In-Reply-To: <1120158124.12143.68.camel@localhost>
References: <1119651942.5105.21.camel@linuxchandra>
	 <1120110730.479552.4689.nullmailer@yamt.dyndns.org>
	 <1120155104.14910.36.camel@linuxchandra>
	 <1120155826.12143.61.camel@localhost>
	 <1120157624.14910.42.camel@linuxchandra>
	 <1120158124.12143.68.camel@localhost>
Content-Type: text/plain
Date: Thu, 30 Jun 2005 12:21:22 -0700
Message-Id: <1120159282.14910.60.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-30 at 12:02 -0700, Dave Hansen wrote:

> > memory controller does not use zone->lock, it only uses zone->lru_lock..
> > I 'll look thru to see if that leads to a deadlock...
> 
> static int
> free_pages_bulk(struct zone *zone, int count,
>                 struct list_head *list, unsigned int order)
> {
> ...
>         spin_lock_irqsave(&zone->lock, flags);
>         while (!list_empty(list) && count--) {
> 		__free_pages_bulk(page, zone, order);
> 
> 		/* can't call the allocator in here: /*
> 		(page);
>         }
>         spin_unlock_irqrestore(&zone->lock, flags);
>         return ret;
> }
> 
> See?

Hmm.... either you are looking at a old set of patches or you do not
have all the patches in the current set. ckrm_clear_page_class is _not_
from free_pages_bulk in the current patchset fully applied :).

chandra
PS: it should not be there in any of the patches in the current
patchset, but is left out due to code rearrangements, I will fix that.
> 
> -- Dave
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
