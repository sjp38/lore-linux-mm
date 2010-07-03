Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A06AE6B01AC
	for <linux-mm@kvack.org>; Sat,  3 Jul 2010 02:36:30 -0400 (EDT)
Message-ID: <4C2EDA6C.7030405@codeaurora.org>
Date: Fri, 02 Jul 2010 23:36:28 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <1278012503.7738.17.camel@c-dwalke-linux.qualc <20100701230056.GD3594@basil.fritz.box>
In-Reply-To: <20100701230056.GD3594@basil.fritz.box>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@jasper.es
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> The standard Linux approach to such a problem is to write
> a library that drivers can use for common functionality, not put a middle 
> layer inbetween. Libraries are much more flexible than layers.

I've been thinking about this statement. Its very true. I use the
genalloc lib which is a great piece of software to manage VCMs
(domains in linux/iommu.h parlance?).

On our hardware we have 3 things we have to do, use the minimum set of
mappings to map a buffer because of the extremely small TLBs in all the
IOMMUs we have to support, use special virtual alignments and direct
various multimedia flows through certain IOMMUs. To support this we:

1. Use the genalloc lib to allocate virtual space for our IOMMUs,
allowing virtual alignment to be specified.

2. Have a maxmunch allocator that manages our own physical pool.

I think I may be able to support this using the iommu interface and
some util functions. The big thing that's lost is the unified topology
management, but as demonstrated that may fall out from a refactor.

Anyhow, sounds like a few things to try. Thanks for the feedback so
far. I'll do some refactoring and see what's missing.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
