Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0256B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:11:56 -0400 (EDT)
Date: Wed, 14 Jul 2010 13:11:49 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
Message-ID: <20100714201149.GA14008@codeaurora.org>
References: <4C3C0032.5020702@codeaurora.org>
 <20100713150311B.fujita.tomonori@lab.ntt.co.jp>
 <20100713121420.GB4263@codeaurora.org>
 <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux@arm.linux.org.uk, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 14, 2010 at 10:59:38AM +0900, FUJITA Tomonori wrote:
> On Tue, 13 Jul 2010 05:14:21 -0700
> Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
> 
> > > You mean that you want to specify this alignment attribute every time
> > > you create an IOMMU mapping? Then you can set segment_boundary_mask
> > > every time you create an IOMMU mapping. It's odd but it should work.
> > 
> > Kinda. I want to forget about IOMMUs, devices and CPUs. I just want to
> > create a mapping that has the alignment I specify, regardless of the
> > mapper. The mapping is created on a VCM and the VCM is associated with
> > a mapper: a CPU, an IOMMU'd device or a direct mapped device.
> 
> Sounds like you can do the above with the combination of the current
> APIs, create a virtual address and then an I/O address.
> 

Yes, and that's what the implementation does - and all the other
implementations that need to do this same thing. Why not solve the
problem once?

> The above can't be a reason to add a new infrastructure includes more
> than 3,000 lines.

Right now its 3000 lines because I haven't converted to a function
pointer based implementation. Once I do that the size of the
implementation will shrink and the code will act as a lib. Users pass
buffer mappers and the lib will ease the management of of those
buffers.

>  
> 
> > > Another possible solution is extending struct dma_attrs. We could add
> > > the alignment attribute to it.
> > 
> > That may be useful, but in the current DMA-API may be seen as
> > redundant info.
> 
> If there is real requirement, we can extend the DMA-API.

If the DMA-API contained functions to allocate virtual space separate
from physical space and reworked how chained buffers functioned it
would probably work - but then things start to look like the VCM API
which does graph based map management.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
