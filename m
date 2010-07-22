Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 341CA6B02AB
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 03:40:25 -0400 (EDT)
Date: Thu, 22 Jul 2010 08:39:17 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
	memory management
Message-ID: <20100722073917.GC6802@n2100.arm.linux.org.uk>
References: <20100715014148.GC2239@codeaurora.org> <20100719082213.GA7421@n2100.arm.linux.org.uk> <20100720221959.GC12250@codeaurora.org> <20100721104356S.fujita.tomonori@lab.ntt.co.jp> <20100722043034.GC22559@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722043034.GC22559@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 09:30:34PM -0700, Zach Pfeffer wrote:
> This goes to the nub of the issue. We need a lot of 1 MB physically
> contiguous chunks. The system is going to fragment and we'll never get
> our 12 1 MB chunks that we'll need, since the DMA API allocator uses
> the system pool it will never succeed.

By the "DMA API allocator" I assume you mean the coherent DMA interface,
The DMA coherent API and DMA streaming APIs are two separate sub-interfaces
of the DMA API and are not dependent on each other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
