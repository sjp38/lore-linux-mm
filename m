Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99055620200
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 22:00:48 -0400 (EDT)
Date: Wed, 14 Jul 2010 10:59:38 +0900
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100713121420.GB4263@codeaurora.org>
References: <4C3C0032.5020702@codeaurora.org>
	<20100713150311B.fujita.tomonori@lab.ntt.co.jp>
	<20100713121420.GB4263@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: zpfeffer@codeaurora.org
Cc: fujita.tomonori@lab.ntt.co.jp, linux@arm.linux.org.uk, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 05:14:21 -0700
Zach Pfeffer <zpfeffer@codeaurora.org> wrote:

> > You mean that you want to specify this alignment attribute every time
> > you create an IOMMU mapping? Then you can set segment_boundary_mask
> > every time you create an IOMMU mapping. It's odd but it should work.
> 
> Kinda. I want to forget about IOMMUs, devices and CPUs. I just want to
> create a mapping that has the alignment I specify, regardless of the
> mapper. The mapping is created on a VCM and the VCM is associated with
> a mapper: a CPU, an IOMMU'd device or a direct mapped device.

Sounds like you can do the above with the combination of the current
APIs, create a virtual address and then an I/O address.

The above can't be a reason to add a new infrastructure includes more
than 3,000 lines.
 

> > Another possible solution is extending struct dma_attrs. We could add
> > the alignment attribute to it.
> 
> That may be useful, but in the current DMA-API may be seen as
> redundant info.

If there is real requirement, we can extend the DMA-API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
