Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 440A66B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 09:24:17 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LO6008GF7WDMY@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 11 Jul 2011 14:24:13 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LO600A7E7WBOW@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 11 Jul 2011 14:24:12 +0100 (BST)
Date: Mon, 11 Jul 2011 15:24:08 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv11 0/8] Contiguous Memory Allocator
In-reply-to: <20110706151112.5c619431.akpm@linux-foundation.org>
Message-id: <001d01cc3fcd$d082a450$7187ecf0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
 <201107051407.17249.arnd@arndb.de>
 <20110706151112.5c619431.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>, 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Thursday, July 07, 2011 12:11 AM Andrew Morton wrote:

> On Tue, 5 Jul 2011 14:07:17 +0200
> Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > On Tuesday 05 July 2011, Marek Szyprowski wrote:
> > > This is yet another round of Contiguous Memory Allocator patches. I
> hope
> > > that I've managed to resolve all the items discussed during the Memory
> > > Management summit at Linaro Meeting in Budapest and pointed later on
> > > mailing lists. The goal is to integrate it as tight as possible with
> > > other kernel subsystems (like memory management and dma-mapping) and
> > > finally merge to mainline.
> >
> > You have certainly addressed all of my concerns, this looks really good
> now!
> >
> > Andrew, can you add this to your -mm tree? What's your opinion on the
> > current state, do you think this is ready for merging in 3.1 or would
> > you want to have more reviews from core memory management people?
> >
> > My reviews were mostly on the driver and platform API side, and I think
> > we're fine there now, but I don't really understand the impacts this has
> > in mm.
> 
> I could review it and put it in there on a preliminary basis for some
> runtime testing.  But the question in my mind is how different will the
> code be after the problems which rmk has identified have been fixed?
> 
> If "not very different" then that effort and testing will have been
> worthwhile.

The issue reported by Russell is very ARM specific and can be solved mostly
in arch/arm/mm/dma-mapping.c, maybe with some minor changes/helpers in
drivers/base/dma-contiguous.c The core part in linux/mm probably won't be
affected by these changes at all.

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
