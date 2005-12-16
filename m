Date: Fri, 16 Dec 2005 09:55:24 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch] New zone ZONE_EASY_RECLAIM take 3. (define ZONE_EASY_RECLAIM)[2/5]
In-Reply-To: <43A1E704.6040106@austin.ibm.com>
References: <20051210193849.4828.Y-GOTO@jp.fujitsu.com> <43A1E704.6040106@austin.ibm.com>
Message-Id: <20051216095136.09EC.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> Sorry for the slow reply.  Hope feedback isn't too late.

Not late. :-)

> >  /*
> > Index: zone_reclaim/mm/page_alloc.c
> > ===================================================================
> > --- zone_reclaim.orig/mm/page_alloc.c	2005-12-10 17:13:15.000000000 +0900
> > +++ zone_reclaim/mm/page_alloc.c	2005-12-10 17:15:10.000000000 +0900
> > @@ -66,7 +66,7 @@ static void fastcall free_hot_cold_page(
> >   * TBD: should special case ZONE_DMA32 machines here - in those we normally
> >   * don't need any ZONE_NORMAL reservation
> >   */
> > -int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = { 256, 256, 32 };
> > +int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = { 256, 256, 256, 32 ,32};
> 
> This line looks wrong.  It looks you are initializing a 4 element array with 5 
> elements.

Oops. I made a mistake. Thanks.


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
