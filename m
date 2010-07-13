Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C585B6B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 01:21:07 -0400 (EDT)
Message-ID: <4C3BF7C1.9040904@codeaurora.org>
Date: Mon, 12 Jul 2010 22:21:05 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <AANLkTinABCSdN6hnXVOvVZ12f1QBMR_UAi62qW8GmlkL@mail.gmail.com> <4C2D908E.9030309@codeaurora.org> <20100710143635.GA10080@8bytes.org>
In-Reply-To: <20100710143635.GA10080@8bytes.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joerg Roedel <joro@8bytes.org>
Cc: Hari Kanigeri <hari.kanigeri@gmail.com>, Daniel Walker <dwalker@codeaurora.org>, Andi Kleen <andi@firstfloor.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Joerg Roedel wrote:
> On Fri, Jul 02, 2010 at 12:09:02AM -0700, Zach Pfeffer wrote:
>> Hari Kanigeri wrote:
>>>> He demonstrated the usage of his code in one of the emails he sent out
>>>> initially. Did you go over that, and what (or how many) step would you
>>>> use with the current code to do the same thing?
>>> -- So is this patch set adding layers and abstractions to help the User ?
>>>
>>> If the idea is to share some memory across multiple devices, I guess
>>> you can achieve the same by calling the map function provided by iommu
>>> module and sharing the mapped address to the 10's or 100's of devices
>>> to access the buffers. You would only need a dedicated virtual pool
>>> per IOMMU device to manage its virtual memory allocations.
>> Yeah, you can do that. My idea is to get away from explicit addressing
>> and encapsulate the "device address to physical address" link into a
>> mapping.
> 
> The DMA-API already does this with the help of IOMMUs if they are
> present. What is the benefit of your approach over that?

The grist to the DMA-API mill is the opaque scatterlist. Each
scatterlist element brings together a physical address and a bus
address that may be different. The set of scatterlist elements
constitute both the set of physical buffers and the mappings to those
buffers. My approach separates these two things into a struct physmem
which contains the set of physical buffers and a struct reservation
which contains the set of bus addresses (or device addresses). Each
element in the struct physmem may be of various lengths (without
resorting to chaining). A map call maps the one set to the other. 

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
