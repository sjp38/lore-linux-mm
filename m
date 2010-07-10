Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CDAF86B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 10:54:02 -0400 (EDT)
Date: Sat, 10 Jul 2010 16:54:00 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100710145400.GB10080@8bytes.org>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com> <20100701193850.GB3594@basil.fritz.box> <4C2D0FF1.6010206@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C2D0FF1.6010206@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Andi Kleen <andi@firstfloor.org>, Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 01, 2010 at 03:00:17PM -0700, Zach Pfeffer wrote:
> Additionally, the current IOMMU interface does not allow users to
> associate one page table with multiple IOMMUs [...]

Thats not true. Multiple IOMMUs are completly handled by the IOMMU
drivers. In the case of the IOMMU-API backend drivers this also includes
the ability to use page-tables on multiple IOMMUs.

> Since the particular topology is run-time configurable all of these
> use-cases and more can be expressed without pushing the topology into
> the low-level IOMMU driver.

The IOMMU driver has to know about the topology anyway because it needs
to know which IOMMU it needs to program for a particular device.

> Already, there are ~20 different IOMMU map implementations in the
> kernel. Had the Linux kernel had the VCMM, many of those
> implementations could have leveraged the mapping and topology
> management of a VCMM, while focusing on a few key hardware specific
> functions (map this physical address, program the page table base
> register).

I partially agree here. All the IOMMU implementations in the Linux
kernel have a lot of functionality in common where code could be
shared. Work to share code has been done in the past by Fujita Tomonori
but there are more places to work on. I am just not sure if a new
front-end API is the right way to do this.

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
