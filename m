Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C96D46B02A9
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 03:52:44 -0400 (EDT)
Date: Thu, 22 Jul 2010 08:51:51 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100722075151.GD6802@n2100.arm.linux.org.uk>
References: <20100713094244.7eb84f1b@lxorguk.ukuu.org.uk> <20100713174519D.fujita.tomonori@lab.ntt.co.jp> <20100713090223.GB20590@n2100.arm.linux.org.uk> <20100714105922D.fujita.tomonori@lab.ntt.co.jp> <20100722035026.GB14176@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722035026.GB14176@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, alan@lxorguk.ukuu.org.uk, randy.dunlap@oracle.com, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, joro@8bytes.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 08:50:26PM -0700, Zach Pfeffer wrote:
> On Wed, Jul 14, 2010 at 10:59:43AM +0900, FUJITA Tomonori wrote:
> > On Tue, 13 Jul 2010 10:02:23 +0100
> > 
> > Zach Pfeffer said this new VCM infrastructure can be useful for
> > video4linux. However, I don't think we need 3,000-lines another
> > abstraction layer to solve video4linux's issue nicely.
> 
> Its only 3000 lines because I haven't converted the code to use
> function pointers.

I don't understand - you've made this claim a couple of times.  I
can't see how converting the code to use function pointers (presumably
to eliminate those switch statements) would reduce the number of lines
of code.

Please explain (or show via new patches) how does converting this to
function pointers significantly reduce the number of lines of code.

We might then be able to put just _one_ of these issues to bed.

> Getting back to the point. There is no API that can handle large
> buffer allocation and sharing with low-level attribute control for
> virtual address spaces outside the CPU.

I think we've dealt with the attribute issue to death now.  Shall we
repeat it again?

> The DMA API et al. take a CPU centric view of virtual space
> management, sharing has to be explicitly written and external virtual
> space management is left up to device driver writers.

I think I've also shown that not to be the case with example code.

The code behind the DMA API can be changed on a per-device basis
(currently on ARM we haven't supported that because no one's asked
for it yet) so that it can support multiple IOMMUs even of multiple
different types.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
