Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BCF8D6B0071
	for <linux-mm@kvack.org>; Thu, 24 Jun 2010 06:12:00 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] mm: iommu: An API to unify IOMMU, CPU and device memory management
References: <1277355096-15596-1-git-send-email-zpfeffer@codeaurora.org>
Date: Thu, 24 Jun 2010 12:11:56 +0200
In-Reply-To: <1277355096-15596-1-git-send-email-zpfeffer@codeaurora.org> (Zach
	Pfeffer's message of "Wed, 23 Jun 2010 21:51:36 -0700")
Message-ID: <876318ager.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: mel@csn.ul.ie, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Zach Pfeffer <zpfeffer@codeaurora.org> writes:

> This patch contains the documentation for and the main header file of
> the API, termed the Virtual Contiguous Memory Manager. Its use would
> allow all of the IOMMU to VM, VM to device and device to IOMMU
> interoperation code to be refactored into platform independent code.

I read all the description and it's still unclear what advantage
this all has over the current architecture? 

At least all the benefits mentioned seem to be rather nebulous.

Can you describe a concrete use case that is improved by this code
directly?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
