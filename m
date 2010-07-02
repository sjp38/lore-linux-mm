Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 29B946B01B6
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 03:33:53 -0400 (EDT)
Message-ID: <4C2D965F.5000206@codeaurora.org>
Date: Fri, 02 Jul 2010 00:33:51 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>  <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>  <20100701101746.3810cc3b.randy.dunlap@oracle.com>  <20100701180241.GA3594@basil.fritz.box>  <1278012503.7738.17.camel@c-dwalke-linux.q <1278021944.7738.43.camel@c-dwalke-linux.qualcomm.com>
In-Reply-To: <1278021944.7738.43.camel@c-dwalke-linux.qualcomm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: Andi Kleen <andi@firstfloor.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Daniel Walker wrote:
> On Thu, 2010-07-01 at 15:00 -0700, Zach Pfeffer wrote:
> 
> 
>> Additionally, the current IOMMU interface does not allow users to
>> associate one page table with multiple IOMMUs unless the user explicitly
>> wrote a muxed device underneith the IOMMU interface. This also could be
>> done, but would have to be done for every such use case. Since the
>> particular topology is run-time configurable all of these use-cases and
>> more can be expressed without pushing the topology into the low-level
>> IOMMU driver.
>>
>> The VCMM takes the long view. Its designed for a future in which the
>> number of IOMMUs will go up and the ways in which these IOMMUs are
>> composed will vary from system to system, and may vary at
>> runtime. Already, there are ~20 different IOMMU map implementations in
>> the kernel. Had the Linux kernel had the VCMM, many of those
>> implementations could have leveraged the mapping and topology management
>> of a VCMM, while focusing on a few key hardware specific functions (map
>> this physical address, program the page table base register).
> 
> So if we include this code which "map implementations" could you
> collapse into this implementations ? Generally , what currently existing
> code can VCMM help to eliminate?

In theory, it can eliminate all code the interoperates between IOMMU,
CPU and non-IOMMU based devices and all the mapping code, alignment,
mapping attribute and special block size support that's been
implemented.


-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
