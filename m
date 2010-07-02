Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A19D66B01B7
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 03:09:04 -0400 (EDT)
Message-ID: <4C2D908E.9030309@codeaurora.org>
Date: Fri, 02 Jul 2010 00:09:02 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <1278012503.7738.17.camel@c-dwalke-linux.qualc <AANLkTinABCSdN6hnXVOvVZ12f1QBMR_UAi62qW8GmlkL@mail.gmail.com>
In-Reply-To: <AANLkTinABCSdN6hnXVOvVZ12f1QBMR_UAi62qW8GmlkL@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hari Kanigeri <hari.kanigeri@gmail.com>
Cc: Daniel Walker <dwalker@codeaurora.org>, Andi Kleen <andi@firstfloor.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hari Kanigeri wrote:
>> He demonstrated the usage of his code in one of the emails he sent out
>> initially. Did you go over that, and what (or how many) step would you
>> use with the current code to do the same thing?
> 
> -- So is this patch set adding layers and abstractions to help the User ?
> 
> If the idea is to share some memory across multiple devices, I guess
> you can achieve the same by calling the map function provided by iommu
> module and sharing the mapped address to the 10's or 100's of devices
> to access the buffers. You would only need a dedicated virtual pool
> per IOMMU device to manage its virtual memory allocations.

Yeah, you can do that. My idea is to get away from explicit addressing
and encapsulate the "device address to physical address" link into a
mapping.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
