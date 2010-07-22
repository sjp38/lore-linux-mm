Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7285E6B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 00:44:57 -0400 (EDT)
Date: Thu, 22 Jul 2010 13:43:26 +0900
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100722043034.GC22559@codeaurora.org>
References: <20100720221959.GC12250@codeaurora.org>
	<20100721104356S.fujita.tomonori@lab.ntt.co.jp>
	<20100722043034.GC22559@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100722134253B.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: zpfeffer@codeaurora.org
Cc: fujita.tomonori@lab.ntt.co.jp, linux@arm.linux.org.uk, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 21:30:34 -0700
Zach Pfeffer <zpfeffer@codeaurora.org> wrote:

> On Wed, Jul 21, 2010 at 10:44:37AM +0900, FUJITA Tomonori wrote:
> > On Tue, 20 Jul 2010 15:20:01 -0700
> > Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
> > 
> > > > I'm not saying that it's reasonable to pass (or even allocate) a 1MB
> > > > buffer via the DMA API.
> > > 
> > > But given a bunch of large chunks of memory, is there any API that can
> > > manage them (asked this on the other thread as well)?
> > 
> > What is the problem about mapping a 1MB buffer with the DMA API?
> > 
> > Possibly, an IOMMU can't find space for 1MB but it's not the problem
> > of the DMA API.
> 
> This goes to the nub of the issue. We need a lot of 1 MB physically
> contiguous chunks. The system is going to fragment and we'll never get
> our 12 1 MB chunks that we'll need, since the DMA API allocator uses
> the system pool it will never succeed. For this reason we reserve a
> pool of 1 MB chunks (and 16 MB, 64 KB etc...) to satisfy our
> requests. This same use case is seen on most embedded "media" engines
> that are getting built today.

We don't need a new abstraction to reserve some memory.

If you want pre-allocated memory pool per device (and share them with
some), the DMA API can for coherent memory (see
dma_alloc_from_coherent). You can extend the DMA API if necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
