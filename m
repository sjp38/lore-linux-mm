Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A65AB6B0248
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 18:44:30 -0400 (EDT)
Message-ID: <4C35034B.6040906@codeaurora.org>
Date: Wed, 07 Jul 2010 15:44:27 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
References: <1278135507-20294-1-git-send-email-zpfeffer@codeaurora.org> <m14oggpepx.fsf@fess.ebiederm.org>
In-Reply-To: <m14oggpepx.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: mel@csn.ul.ie, andi@firstfloor.org, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:
> Zach Pfeffer <zpfeffer@codeaurora.org> writes:
> 
>> This patch contains the documentation for the API, termed the Virtual
>> Contiguous Memory Manager. Its use would allow all of the IOMMU to VM,
>> VM to device and device to IOMMU interoperation code to be refactored
>> into platform independent code.
>>
>> Comments, suggestions and criticisms are welcome and wanted.
> 
> How does this differ from the dma api?

The DMA API handles the allocation and use of DMA channels. It can
configure physical transfer settings, manage scatter-gather lists,
etc. 

The VCM is a different thing. The VCM allows a Virtual Contiguous
Memory region to be created and associated with a device that
addresses the bus virtually or physically. If the bus is addressed
physically the Virtual Contiguous Memory is one-to-one mapped. If the
bus is virtually mapped than a contiguous virtual reservation may be
backed by a discontiguous list of physical blocks. This discontiguous
list could be a SG list of just a list of physical blocks that would
back the entire virtual reservation.

The VCM allows all device buffers to be passed between all devices in
the system without passing those buffers through each domain's
API. This means that instead of writing code to interoperate between
DMA engines, IOMMU mapped spaces, CPUs and physically addressed
devices the user can simply target a device with a buffer using the
same API regardless of how that device maps or otherwise accesses the
buffer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
