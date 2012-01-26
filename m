Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 4ADBE6B005C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 10:48:35 -0500 (EST)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LYE0010IX8XNO@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 26 Jan 2012 15:48:33 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYE00BLRX8WHM@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Jan 2012 15:48:33 +0000 (GMT)
Date: Thu, 26 Jan 2012 16:48:29 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv19 00/15] Contiguous Memory Allocator
In-reply-to: <201201261531.40551.arnd@arndb.de>
Message-id: <009f01ccdc41$f30a5f70$d91f1e50$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <201201261531.40551.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>

Hello,

On Thursday, January 26, 2012 4:32 PM Arnd Bergmann wrote:

> On Thursday 26 January 2012, Marek Szyprowski wrote:
> > Welcome everyone!
> >
> > Yes, that's true. This is yet another release of the Contiguous Memory
> > Allocator patches. This version mainly includes code cleanups requested
> > by Mel Gorman and a few minor bug fixes.
> 
> Hi Marek,
> 
> Thanks for keeping up this work! I really hope it works out for the
> next merge window.
> 
> > TODO (optional):
> > - implement support for contiguous memory areas placed in HIGHMEM zone
> > - resolve issue with movable pages with pending io operations
> 
> Can you clarify these? I believe the contiguous memory areas in highmem
> is something that should really be after the existing code is merged
> into the upstream kernel and should better not be listed as TODO here.

Ok, I will remove it from the TODO list. Core memory management is very 
little dependence on HIGHMEM, it is more about DMA-mapping framework to 
be aware that there might be no lowmem mappings for the allocated pages.
This can be easily added once the initial version got merged.
 
> I haven't followed the last two releases so closely. It seems that
> in v17 the movable pages with pending i/o was still a major problem
> but in v18 you added a solution. Is that right? What is still left
> to be done here then?

Since v18 the failed allocation is retried in a bit different place in 
the contiguous memory area what heavily increased overall reliability.

This can be improved by making cma a bit more aware about pending io 
operations, but I want to leave this after the initial merge.

I think that there are no major issues left to be resolved now.

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
