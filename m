Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 047296B004D
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 07:31:13 -0400 (EDT)
Date: Fri, 23 Oct 2009 13:31:10 +0200 (CEST)
From: Tobias Oetiker <tobi@oetiker.ch>
Subject: Re: [PATCH 4/5] page allocator: Pre-emptively wake kswapd when
 high-order watermarks are hit
In-Reply-To: <20091023112512.GW11778@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0910231329550.26462@sebohet.brgvxre.pu>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0910221227010.21601@chino.kir.corp.google.com> <20091023091334.GV11778@csn.ul.ie> <alpine.DEB.2.00.0910230229010.28109@chino.kir.corp.google.com>
 <20091023112512.GW11778@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel,

Today Mel Gorman wrote:

> On Fri, Oct 23, 2009 at 02:36:53AM -0700, David Rientjes wrote:
> > On Fri, 23 Oct 2009, Mel Gorman wrote:
> >
> > > > Hmm, is this really supposed to be added to __alloc_pages_high_priority()?
> > > > By the patch description I was expecting kswapd to be woken up
> > > > preemptively whenever the preferred zone is below ALLOC_WMARK_LOW and
> > > > we're known to have just allocated at a higher order, not just when
> > > > current was oom killed (when we should already be freeing a _lot_ of
> > > > memory soon) or is doing a higher order allocation during direct reclaim.
> > > >
> > >
> > > It was a somewhat arbitrary choice to have it trigger in the event high
> > > priority allocations were happening frequently.
> > >
> >
> > I don't quite understand, users of PF_MEMALLOC shouldn't be doing these
> > higher order allocations and if ALLOC_NO_WATERMARKS is by way of the oom
> > killer, we should be freeing a substantial amount of memory imminently
> > when it exits that waking up kswapd would be irrelevant.
> >
>
> I agree. I think it's highly unlikely this patch will make any
> difference but I wanted to eliminate it as a possibility. Patch 3 and 4
> were previously one patch that were tested together.

hi hi ... I have tested '3 only' this morning, and the allocation
problems started again ... so for me 3 alone does not work while
3+4 does.

cheers
tobi

-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
