Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0485B9000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 11:00:24 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [PATCH 6/8] drivers: add Contiguous Memory Allocator
Date: Wed, 6 Jul 2011 16:59:45 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <20110706142345.GC8286@n2100.arm.linux.org.uk> <alpine.LFD.2.00.1107061034200.14596@xanadu.home>
In-Reply-To: <alpine.LFD.2.00.1107061034200.14596@xanadu.home>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201107061659.45253.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-media@vger.kernel.org

On Wednesday 06 July 2011, Nicolas Pitre wrote:
> On Wed, 6 Jul 2011, Russell King - ARM Linux wrote:
> 
> > Another issue is that when a platform has restricted DMA regions,
> > they typically don't fall into the highmem zone.  As the dmabounce
> > code allocates from the DMA coherent allocator to provide it with
> > guaranteed DMA-able memory, that would be rather inconvenient.
> 
> Do we encounter this in practice i.e. do those platforms requiring large 
> contiguous allocations motivating this work have such DMA restrictions?

You can probably find one or two of those, but we don't have to optimize
for that case. I would at least expect the maximum size of the allocation
to be smaller than the DMA limit for these, and consequently mandate that
they define a sufficiently large CONSISTENT_DMA_SIZE for the crazy devices,
or possibly add a hack to unmap some low memory and call
dma_declare_coherent_memory() for the device.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
