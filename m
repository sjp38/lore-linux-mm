Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 450C26B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 23:50:30 -0400 (EDT)
Date: Wed, 21 Jul 2010 20:50:26 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100722035026.GB14176@codeaurora.org>
References: <20100713094244.7eb84f1b@lxorguk.ukuu.org.uk>
 <20100713174519D.fujita.tomonori@lab.ntt.co.jp>
 <20100713090223.GB20590@n2100.arm.linux.org.uk>
 <20100714105922D.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100714105922D.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux@arm.linux.org.uk, alan@lxorguk.ukuu.org.uk, randy.dunlap@oracle.com, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, joro@8bytes.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 14, 2010 at 10:59:43AM +0900, FUJITA Tomonori wrote:
> On Tue, 13 Jul 2010 10:02:23 +0100
> 
> Zach Pfeffer said this new VCM infrastructure can be useful for
> video4linux. However, I don't think we need 3,000-lines another
> abstraction layer to solve video4linux's issue nicely.

Its only 3000 lines because I haven't converted the code to use
function pointers.

> I can't find any reasonable reasons that we need to merge VCM; seems
> that the combination of the current APIs (or with some small
> extensions) can work for the issues that VCM tries to solve.

Getting back to the point. There is no API that can handle large
buffer allocation and sharing with low-level attribute control for
virtual address spaces outside the CPU. At this point if you need to
work with big buffers, 1 MB and 16 MB etc, and map those big buffers
to non-CPU virtual spaces you need to explicitly carve them out and
set up the mappings and sharing by hand. Its reasonable to have an API
that can do this especially since IOMMUs are going to become more
prevalent. The DMA API et al. take a CPU centric view of virtual space
management, sharing has to be explicitly written and external virtual
space management is left up to device driver writers. Given a system
where each device has an IOMMU or a MMU the whole concept of a
scatterlist goes away. The VCM API gets a jump on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
