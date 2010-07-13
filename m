Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 889726B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 01:27:53 -0400 (EDT)
Message-ID: <4C3BF958.8020304@codeaurora.org>
Date: Mon, 12 Jul 2010 22:27:52 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com> <20100701193850.GB3594@basil.fritz.box> <4C2D0FF1.6010206@codeaurora.org> <20100710145400.GB10080@8bytes.org>
In-Reply-To: <20100710145400.GB10080@8bytes.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joerg Roedel <joro@8bytes.org>
Cc: Andi Kleen <andi@firstfloor.org>, Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Joerg Roedel wrote:
> On Thu, Jul 01, 2010 at 03:00:17PM -0700, Zach Pfeffer wrote:
>> Additionally, the current IOMMU interface does not allow users to
>> associate one page table with multiple IOMMUs [...]
> 
> Thats not true. Multiple IOMMUs are completly handled by the IOMMU
> drivers. In the case of the IOMMU-API backend drivers this also includes
> the ability to use page-tables on multiple IOMMUs.

Yeah. I see that now.

> 
>> Since the particular topology is run-time configurable all of these
>> use-cases and more can be expressed without pushing the topology into
>> the low-level IOMMU driver.
> 
> The IOMMU driver has to know about the topology anyway because it needs
> to know which IOMMU it needs to program for a particular device.

Perhaps, but why not create a VCM which can be shared across all
mappers in the system? Why bury it in a device driver and make all
IOMMU device drivers managed their own virtual spaces? Practically
this would entail a minor refactor to the fledging IOMMU interface;
adding associate and activate ops.

> 
>> Already, there are ~20 different IOMMU map implementations in the
>> kernel. Had the Linux kernel had the VCMM, many of those
>> implementations could have leveraged the mapping and topology
>> management of a VCMM, while focusing on a few key hardware specific
>> functions (map this physical address, program the page table base
>> register).
> 
> I partially agree here. All the IOMMU implementations in the Linux
> kernel have a lot of functionality in common where code could be
> shared. Work to share code has been done in the past by Fujita Tomonori
> but there are more places to work on. I am just not sure if a new
> front-end API is the right way to do this.

I don't really think its a new front end API. Its just an API that
allows easier mapping manipulation than the current APIs.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
