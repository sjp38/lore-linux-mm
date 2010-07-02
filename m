Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 13CED6B01B6
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 03:29:58 -0400 (EDT)
Message-ID: <4C2D9575.9030002@codeaurora.org>
Date: Fri, 02 Jul 2010 00:29:57 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <1278012503.7738.17.camel@c-dwalke-linux.qualc <AANLkTilQnopqrS-KrR3btOIkH68fIEdipWFF6fkO6fNA@mail.gmail.com>
In-Reply-To: <AANLkTilQnopqrS-KrR3btOIkH68fIEdipWFF6fkO6fNA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hari Kanigeri <hari.kanigeri@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@jasper.es
List-ID: <linux-mm.kvack.org>

Hari Kanigeri wrote:
>> The VCMM takes the long view. Its designed for a future in which the
>> number of IOMMUs will go up and the ways in which these IOMMUs are
>> composed will vary from system to system, and may vary at
>> runtime. Already, there are ~20 different IOMMU map implementations in
>> the kernel. Had the Linux kernel had the VCMM, many of those
>> implementations could have leveraged the mapping and topology management
>> of a VCMM, while focusing on a few key hardware specific functions (map
>> this physical address, program the page table base register).
>>
> 
> -- Sounds good.
> Did you think of a way to handle the cases where one of the Device
> that is using the mapped address crashed ?
> How is the physical address unbacked in this case ?

Actually the API takes care of that by design. Since the physical
space is managed apart from the mapper the mapper can crash and not
affect the physical memory allocation.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
