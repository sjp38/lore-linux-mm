Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0FBA26B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 14:56:08 -0400 (EDT)
Date: Wed, 1 Jun 2011 20:55:58 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
In-Reply-To: <20110601181918.GO3660@n2100.arm.linux.org.uk>
Message-ID: <alpine.LFD.2.02.1106012043080.3078@ionos>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com> <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com> <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com> <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
 <20110601181918.GO3660@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: David Rientjes <rientjes@google.com>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 1 Jun 2011, Russell King - ARM Linux wrote:

> On Wed, Jun 01, 2011 at 10:23:15AM -0700, David Rientjes wrote:
> > On Wed, 1 Jun 2011, Dmitry Eremin-Solenikov wrote:
> > 
> > > I've hit this with IrDA driver on PXA. Also I've seen the report regarding
> > > other ARM platform (ep-something). Thus I've included Russell in the cc.
> > > 
> > 
> > So you want to continue to allow the page allocator to return pages from 
> > anywhere, even when GFP_DMA is specified, just as though it was lowmem?
> 
> No.  What *everyone* is asking for is to allow the situation which has
> persisted thus far to continue for ONE MORE RELEASE but with a WARNING
> so that these problems can be found without causing REGRESSIONS.
> 
> That is NOT an unreasonable request, but it seems that its far too much
> to ask of you.

Full ack.

David,

stop that nonsense already. You changed the behaviour and broke stuff
which was working fine before for whatever reason. That behaviour was
in the kernel for ages and we tolerated the abuse.

So making it a warning for this release and then break stuff which has
not been fixed is a sensible request and the only sensible approach.

If you think that you need to force that behaviour change now, then
you better go and audit _ALL_ GFP_DMA users yourself for correctness
and fix them case by case either by replacing the GFP_DMA flag or by
selecting ZONE_DMA with a proper changelog for every instance.

It's not up to your total ignorance of reality to break stuff at will
and then paper over the problems you caused by selecting ZONE_DMA
which will keep the abusers around forever.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
