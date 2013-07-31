Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id E73E96B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 07:49:10 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MQS009I2U5KS840@mailout3.samsung.com> for
 linux-mm@kvack.org; Wed, 31 Jul 2013 20:49:09 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH] Revert
 "mm/memory-hotplug: fix lowmem count overflow when offline pages"
Date: Wed, 31 Jul 2013 13:48:51 +0200
Message-id: <3049413.HnxJdeugZK@amdc1032>
In-reply-to: <1572085.gN7iX7IvMe@amdc1032>
References: <1375260602-2462-1-git-send-email-jy0922.shim@samsung.com>
 <1572085.gN7iX7IvMe@amdc1032>
MIME-version: 1.0
Content-transfer-encoding: 7Bit
Content-type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonyoung Shim <jy0922.shim@samsung.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, liuj97@gmail.com, kosaki.motohiro@gmail.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wednesday, July 31, 2013 01:17:46 PM Bartlomiej Zolnierkiewicz wrote:
> 
> Hi,
> 
> On Wednesday, July 31, 2013 05:50:02 PM Joonyoung Shim wrote:
> > This reverts commit cea27eb2a202959783f81254c48c250ddd80e129.
> 
> Could you please also include commit descriptions, i.e.
> commit cea27eb2a202959783f81254c48c250ddd80e129 ("mm/memory-hotplug: fix
> lowmem count overflow when offline pages")?
> 
> > Fixed to adjust totalhigh_pages when hot-removing memory by commit
> > 3dcc0571cd64816309765b7c7e4691a4cadf2ee7, so that commit occurs
> > duplicated decreasing of totalhigh_pages.
> 
> Could you please describe it a bit more (because it is non-obvious) how
> the commit cea27eb effectively does the same totalhigh_pages adjustment
> that is present in the commit 3dcc057?

Err, the other way around. How the commit 3dcc057 ("mm: correctly update
zone->managed_pages") does what cea27eb ("mm/memory-hotplug: fix lowmem
count overflow when offline pages") did.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics

> > Signed-off-by: Joonyoung Shim <jy0922.shim@samsung.com>
> > ---
> > The commit cea27eb2a202959783f81254c48c250ddd80e129 is only for stable,
> > is it right?
> 
> It is in Linus' tree now but you're probably right that it should be
> limited to stable tree.
> 
> Best regards,
> --
> Bartlomiej Zolnierkiewicz
> Samsung R&D Institute Poland
> Samsung Electronics
> 
> >  mm/page_alloc.c | 4 ----
> >  1 file changed, 4 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index b100255..2b28216 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -6274,10 +6274,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
> >  		list_del(&page->lru);
> >  		rmv_page_order(page);
> >  		zone->free_area[order].nr_free--;
> > -#ifdef CONFIG_HIGHMEM
> > -		if (PageHighMem(page))
> > -			totalhigh_pages -= 1 << order;
> > -#endif
> >  		for (i = 0; i < (1 << order); i++)
> >  			SetPageReserved((page+i));
> >  		pfn += (1 << order);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
