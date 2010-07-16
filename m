Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 658C96B02A3
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 04:00:25 -0400 (EDT)
Date: Fri, 16 Jul 2010 08:58:56 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
	memory management
Message-ID: <20100716075856.GC16124@n2100.arm.linux.org.uk>
References: <4C3C0032.5020702@codeaurora.org> <20100713150311B.fujita.tomonori@lab.ntt.co.jp> <20100713121420.GB4263@codeaurora.org> <20100714104353B.fujita.tomonori@lab.ntt.co.jp> <20100714201149.GA14008@codeaurora.org> <20100714220536.GE18138@n2100.arm.linux.org.uk> <20100715012958.GB2239@codeaurora.org> <20100715085535.GC26212@n2100.arm.linux.org.uk> <AANLkTinVZeaZxt_lWKhjKa0dqhu3_j3BRNySO-2LvMdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinVZeaZxt_lWKhjKa0dqhu3_j3BRNySO-2LvMdw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Tim HRM <zt.tmzt@gmail.com>
Cc: Zach Pfeffer <zpfeffer@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 15, 2010 at 08:48:36PM -0400, Tim HRM wrote:
> Interesting, since I seem to remember the MSM devices mostly conduct
> IO through regions of normal RAM, largely accomplished through
> ioremap() calls.
> 
> Without more public domain documentation of the MSM chips and AMSS
> interfaces I wouldn't know how to avoid this, but I can imagine it
> creates a bit of urgency for Qualcomm developers as they attempt to
> upstream support for this most interesting SoC.

As the patch has been out for RFC since early April on the linux-arm-kernel
mailing list (Subject: [RFC] Prohibit ioremap() on kernel managed RAM),
and no comments have come back from Qualcomm folk.

The restriction on creation of multiple V:P mappings with differing
attributes is also fairly hard to miss in the ARM architecture
specification when reading the sections about caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
