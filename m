Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4KHDOwA020963
	for <linux-mm@kvack.org>; Fri, 20 May 2005 13:13:24 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4KHDNi4123874
	for <linux-mm@kvack.org>; Fri, 20 May 2005 13:13:23 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4KHDNbX017083
	for <linux-mm@kvack.org>; Fri, 20 May 2005 13:13:23 -0400
Date: Fri, 20 May 2005 10:06:47 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [ckrm-tech] [PATCH 2/6] CKRM: Core framework support
Message-ID: <20050520170647.GC28304@chandralinux.beaverton.ibm.com>
References: <20050519003205.GA25232@chandralinux.beaverton.ibm.com> <20050520022732.A6646717AE@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050520022732.A6646717AE@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 20, 2005 at 11:27:31AM +0900, KUROSAWA Takahiro wrote:
> Hi,
> 
> On Wed, 18 May 2005 17:32:05 -0700
> Chandra Seetharaman <sekharan@us.ibm.com> wrote:
> 
> > Index: linux-2612-rc3/mm/page_alloc.c
> > ===================================================================
> > --- linux-2612-rc3.orig/mm/page_alloc.c
> > +++ linux-2612-rc3/mm/page_alloc.c
> > @@ -752,7 +752,7 @@ __alloc_pages(unsigned int __nocast gfp_
> >  	 */
> >  	can_try_harder = (unlikely(rt_task(p)) && !in_interrupt()) || !wait;
> >  
> > -	if (!ckrm_class_limit_ok(ckrm_get_mem_class(p)))
> > +	if (!ckrm_class_limit_ok(ckrm_task_memclass(p)))
> >  		return NULL;
> >  
> >  	zones = zonelist->zones;  /* the list of zones suitable for gfp_mask */
> 
> __alloc_pages() seems to look at the limit of the interrupted task
> when an interrupt handler calls __alloc_pages().  It might be better
> not to use ckrm_class_limit_ok() in in_interrupt() case, as we can't 
> assume that the interrupt is caused by the interrupted task.

Sounds valid... I had it before that way, for for some other reasoning of
mine. will get it back.
> 
> In can_try_harder case, how about trying to reclaim pages that belong
> to the class if !ckrm_class_limit_ok() ?

Sounds a good idea. will do it.

Thanks for your comments.
> 
> Regards,
> 
> -- 
> KUROSAWA, Takahiro

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
