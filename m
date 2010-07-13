Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C6DB86201FE
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 08:14:25 -0400 (EDT)
Date: Tue, 13 Jul 2010 05:14:21 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
Message-ID: <20100713121420.GB4263@codeaurora.org>
References: <4C366678.60605@codeaurora.org>
 <20100712102435B.fujita.tomonori@lab.ntt.co.jp>
 <4C3C0032.5020702@codeaurora.org>
 <20100713150311B.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100713150311B.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux@arm.linux.org.uk, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 03:03:25PM +0900, FUJITA Tomonori wrote:
> On Mon, 12 Jul 2010 22:57:06 -0700
> Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
> 
> > FUJITA Tomonori wrote:
> > > On Thu, 08 Jul 2010 16:59:52 -0700
> > > Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
> > > 
> > >> The problem I'm trying to solve boils down to this: map a set of
> > >> contiguous physical buffers to an aligned IOMMU address. I need to
> > >> allocate the set of physical buffers in a particular way: use 1 MB
> > >> contiguous physical memory, then 64 KB, then 4 KB, etc. and I need to
> > >> align the IOMMU address in a particular way.
> > > 
> > > Sounds like the DMA API already supports what you want.
> > > 
> > > You can set segment_boundary_mask in struct device_dma_parameters if
> > > you want to align the IOMMU address. See IOMMU implementations that
> > > support dma_get_seg_boundary() properly.
> > 
> > That function takes the wrong argument in a VCM world:
> > 
> > unsigned long dma_get_seg_boundary(struct device *dev);
> > 
> > The boundary should be an attribute of the device side mapping,
> > independent of the device. This would allow better code reuse.
> 
> You mean that you want to specify this alignment attribute every time
> you create an IOMMU mapping? Then you can set segment_boundary_mask
> every time you create an IOMMU mapping. It's odd but it should work.

Kinda. I want to forget about IOMMUs, devices and CPUs. I just want to
create a mapping that has the alignment I specify, regardless of the
mapper. The mapping is created on a VCM and the VCM is associated with
a mapper: a CPU, an IOMMU'd device or a direct mapped device.

> 
> Another possible solution is extending struct dma_attrs. We could add
> the alignment attribute to it.

That may be useful, but in the current DMA-API may be seen as
redundant info.

--
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
