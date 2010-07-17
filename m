Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 173EF6B02A3
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 20:01:12 -0400 (EDT)
Date: Fri, 16 Jul 2010 17:01:08 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
Message-ID: <20100717000108.GB21293@labbmf-linux.quicinc.com>
References: <4C3C0032.5020702@codeaurora.org>
 <20100713150311B.fujita.tomonori@lab.ntt.co.jp>
 <20100713121420.GB4263@codeaurora.org>
 <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
 <20100714201149.GA14008@codeaurora.org>
 <20100714220536.GE18138@n2100.arm.linux.org.uk>
 <20100715012958.GB2239@codeaurora.org>
 <20100715085535.GC26212@n2100.arm.linux.org.uk>
 <AANLkTinVZeaZxt_lWKhjKa0dqhu3_j3BRNySO-2LvMdw@mail.gmail.com>
 <20100716075856.GC16124@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100716075856.GC16124@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Tim HRM <zt.tmzt@gmail.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On 16 Jul 10 08:58, Russell King - ARM Linux wrote:
> On Thu, Jul 15, 2010 at 08:48:36PM -0400, Tim HRM wrote:
> > Interesting, since I seem to remember the MSM devices mostly conduct
> > IO through regions of normal RAM, largely accomplished through
> > ioremap() calls.
> > 
> > Without more public domain documentation of the MSM chips and AMSS
> > interfaces I wouldn't know how to avoid this, but I can imagine it
> > creates a bit of urgency for Qualcomm developers as they attempt to
> > upstream support for this most interesting SoC.
> 
> As the patch has been out for RFC since early April on the linux-arm-kernel
> mailing list (Subject: [RFC] Prohibit ioremap() on kernel managed RAM),
> and no comments have come back from Qualcomm folk.

We are investigating the impact of this change on us, and I
will send out more detailed comments next week.

> 
> The restriction on creation of multiple V:P mappings with differing
> attributes is also fairly hard to miss in the ARM architecture
> specification when reading the sections about caches.
> 

Larry Bassel

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
