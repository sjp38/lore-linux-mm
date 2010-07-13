Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 930F26B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 01:52:45 -0400 (EDT)
Message-ID: <4C3BFF2B.40006@codeaurora.org>
Date: Mon, 12 Jul 2010 22:52:43 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com> <20100701193850.GB3594@basil.fritz.box> <4C2D0FF1.6010206@codeaurora.org> <20100701230056.GD3594@basil.fritz.box> <4C2D847E.5080602@codeaurora.org> <20100710151111.GD10080@8bytes.org>
In-Reply-To: <20100710151111.GD10080@8bytes.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joerg Roedel <joro@8bytes.org>
Cc: Andi Kleen <andi@firstfloor.org>, Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Joerg Roedel wrote:
> On Thu, Jul 01, 2010 at 11:17:34PM -0700, Zach Pfeffer wrote:
>> Andi Kleen wrote:
> 
>>> Hmm? dma_map_* does not change any CPU mappings. It only sets up
>>> DMA mapping(s).
>> Sure, but I was saying that iommu_map() doesn't just set up the IOMMU
>> mappings, its sets up both the iommu and kernel buffer mappings.
> 
> What do you mean by kernel buffer mappings?

In-kernel mappings whose addresses can be dereferenced. 

> 
> 
>>> That assumes that all the IOMMUs on the system support the same page table
>>> format, right?
>> Actually no. Since the VCMM abstracts a page-table as a Virtual
>> Contiguous Region (VCM) a VCM can be associated with any device,
>> regardless of their individual page table format.
> 
> The IOMMU-API abstracts a page-table as a domain which can also be
> associated with any device (behind an iommu).

It does, but only by convention. The domain member is just a big
catchall void *. It would be more useful to factor out a VCM
abstraction, with associated ops. As it stands all IOMMU device driver
writters have to re-invent IOMMU virtual address management.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
