Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 308A76B0092
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 02:02:02 -0500 (EST)
Received: from epmmp1 (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Exchange Server 7u4-19.01 64bit (built Sep  7
 2010)) with ESMTP id <0LEY00AGS8VB3V20@mailout3.samsung.com> for
 linux-mm@kvack.org; Thu, 13 Jan 2011 16:01:59 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0LEY00M7G8V4U8@mmp1.samsung.com> for linux-mm@kvack.org; Thu,
 13 Jan 2011 16:01:59 +0900 (KST)
Date: Thu, 13 Jan 2011 08:01:51 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv8 00/12] Contiguous Memory Allocator
In-reply-to: <alpine.LFD.2.00.1101121357580.25498@xanadu.home>
Message-id: <002f01cbb2ef$c55c00a0$501401e0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
 <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
 <20101223100642.GD3636@n2100.arm.linux.org.uk>
 <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com>
 <20101223121917.GG3636@n2100.arm.linux.org.uk>
 <00ec01cba2a2$af20b8b0$0d622a10$%szyprowski@samsung.com>
 <20101223134432.GJ3636@n2100.arm.linux.org.uk>
 <001c01cbb289$864391f0$92cab5d0$%szyprowski@samsung.com>
 <alpine.LFD.2.00.1101121357580.25498@xanadu.home>
Sender: owner-linux-mm@kvack.org
To: 'Nicolas Pitre' <nico@fluxnic.net>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Kyungmin Park' <kmpark@infradead.org>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linux-mm@kvack.org, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

Hello,

On Wednesday, January 12, 2011 8:04 PM Nicolas Pitre wrote:

> On Wed, 12 Jan 2011, Marek Szyprowski wrote:
> 
> > I understand that modifying L1 page tables is definitely not a proper way of
> > handling this. It simply costs too much. But what if we consider that the DMA
> > memory can be only allocated from a specific range of the system memory?
> > Assuming that this range of memory is known during the boot time, it CAN be
> > mapped with two-level of tables in MMU. First level mapping will stay the
> > same all the time for all processes, but it would be possible to unmap the
> > pages required for DMA from the second level mapping what will be visible
> > from all the processes at once.
> 
> How much memory are we talking about?  What is the typical figure?

One typical scenario we would like to support is full-hd decoding. One frame is
about 4MB (1920x1080x2 ~= 4MB). Depending on the codec, it may require up to 15
buffers what gives about 60MB. This simple calculation does not include memory
for the framebuffer, temporary buffers for the hardware codec and buffers for 
the stream.

> > Is there any reason why such solution won't work?
> 
> It could work indeed.
> 
> One similar solution that is already in place is to use highmem for that
> reclaimable DMA memory.  It is easy to ensure affected highmem pages are
> not mapped in kernel space.  And you can decide at boot time how many
> highmem pages you want even if the system has less that 1GB of RAM.

Hmmm, right, this might also help solving the problem.

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
