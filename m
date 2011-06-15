Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3A0C56B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 03:12:15 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LMT00GA1LCCT3@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Jun 2011 08:12:12 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMT00DRXLCBM1@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Jun 2011 08:12:11 +0100 (BST)
Date: Wed, 15 Jun 2011 09:11:39 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
In-reply-to: <201106142030.07549.arnd@arndb.de>
Message-id: <000501cc2b2b$789a54b0$69cefe10$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <201106141803.00876.arnd@arndb.de> <op.vw2r3xrj3l0zgt@mnazarewicz-glaptop>
 <201106142030.07549.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>, 'Michal Nazarewicz' <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

Hello,

On Tuesday, June 14, 2011 8:30 PM Arnd Bergmann wrote:

> On Tuesday 14 June 2011 18:58:35 Michal Nazarewicz wrote:
> > On Tue, 14 Jun 2011 18:03:00 +0200, Arnd Bergmann wrote:
> > > For all I know, that is something that is only true for a few very
> > > special Samsung devices,
> >
> > Maybe.  I'm just answering your question. :)
> >
> > Ah yes, I forgot that separate regions for different purposes could
> > decrease fragmentation.
> 
> That is indeed a good point, but having a good allocator algorithm
> could also solve this. I don't know too much about these allocation
> algorithms, but there are probably multiple working approaches to this.
> 
> > > I would suggest going forward without having multiple regions:
> >
> > Is having support for multiple regions a bad thing?  Frankly,
> > removing this support will change code from reading context passed
> > as argument to code reading context from global variable.  Nothing
> > is gained; functionality is lost.
> 
> What is bad IMHO is making them the default, which forces the board
> code to care about memory management details. I would much prefer
> to have contiguous allocation parameters tuned automatically to just
> work on most boards before we add ways to do board-specific hacks.

I see your concerns, but I really wonder how to determine the properties
of the global/default cma pool. You definitely don't want to give all
available memory o CMA, because it will have negative impact on kernel
operation (kernel really needs to allocate unmovable pages from time to
time). 

The only solution I see now is to provide Kconfig entry to determine
the size of the global CMA pool, but this still have some issues,
especially for multi-board kernels (each board probably will have
different amount of RAM and different memory-consuming devices
available). It looks that each board startup code still might need to
tweak the size of CMA pool. I can add a kernel command line option for
it, but such solution also will not solve all the cases (afair there
was a discussion about kernel command line parameters for memory 
configuration and the conclusion was that it should be avoided).

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
