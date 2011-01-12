Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D8B8C6B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 14:04:34 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN; charset=US-ASCII
Received: from xanadu.home ([66.130.28.92]) by vl-mh-mrz21.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-8.01 (built Dec 16 2008; 32bit))
 with ESMTP id <0LEX00D5IBMGXQ10@vl-mh-mrz21.ip.videotron.ca> for
 linux-mm@kvack.org; Wed, 12 Jan 2011 14:03:53 -0500 (EST)
Date: Wed, 12 Jan 2011 14:04:12 -0500 (EST)
From: Nicolas Pitre <nico@fluxnic.net>
Subject: RE: [PATCHv8 00/12] Contiguous Memory Allocator
In-reply-to: <001c01cbb289$864391f0$92cab5d0$%szyprowski@samsung.com>
Message-id: <alpine.LFD.2.00.1101121357580.25498@xanadu.home>
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
 <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
 <20101223100642.GD3636@n2100.arm.linux.org.uk>
 <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com>
 <20101223121917.GG3636@n2100.arm.linux.org.uk>
 <00ec01cba2a2$af20b8b0$0d622a10$%szyprowski@samsung.com>
 <20101223134432.GJ3636@n2100.arm.linux.org.uk>
 <001c01cbb289$864391f0$92cab5d0$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Kyungmin Park' <kmpark@infradead.org>, 'Michal Nazarewicz' <m.nazarewicz@samsung.com>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linux-mm@kvack.org, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2011, Marek Szyprowski wrote:

> I understand that modifying L1 page tables is definitely not a proper way of
> handling this. It simply costs too much. But what if we consider that the DMA
> memory can be only allocated from a specific range of the system memory?
> Assuming that this range of memory is known during the boot time, it CAN be
> mapped with two-level of tables in MMU. First level mapping will stay the
> same all the time for all processes, but it would be possible to unmap the
> pages required for DMA from the second level mapping what will be visible
> from all the processes at once.

How much memory are we talking about?  What is the typical figure?

> Is there any reason why such solution won't work?

It could work indeed.

One similar solution that is already in place is to use highmem for that 
reclaimable DMA memory.  It is easy to ensure affected highmem pages are 
not mapped in kernel space.  And you can decide at boot time how many 
highmem pages you want even if the system has less that 1GB of RAM.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
