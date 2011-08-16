Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 862E76B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 06:18:08 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LQ000GURNA46I00@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Aug 2011 11:18:04 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LQ0000Z0NA3ZG@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Aug 2011 11:18:03 +0100 (BST)
Date: Tue, 16 Aug 2011 12:17:30 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 7/9] ARM: DMA: steal memory for DMA coherent mappings
In-reply-to: <201108121453.05898.arnd@arndb.de>
Message-id: <004301cc5bfd$b50048d0$1f00da70$%szyprowski@samsung.com>
Content-language: pl
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com>
 <1313146711-1767-8-git-send-email-m.szyprowski@samsung.com>
 <201108121453.05898.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Friday, August 12, 2011 2:53 PM Arnd Bergmann wrote:

> On Friday 12 August 2011, Marek Szyprowski wrote:
> >
> > From: Russell King <rmk+kernel@arm.linux.org.uk>
> >
> > Steal memory from the kernel to provide coherent DMA memory to drivers.
> > This avoids the problem with multiple mappings with differing attributes
> > on later CPUs.
> >
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > [m.szyprowski: rebased onto 3.1-rc1]
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> 
> Hi Marek,
> 
> Is this the same patch that Russell had to revert because it didn't
> work on some of the older machines, in particular those using
> dmabounce?

Yes.
 
> I thought that our discussion ended with the plan to use this only
> for ARMv6+ (which has a problem with double mapping) but not on ARMv5
> and below (which don't have this problem but might need dmabounce).

Ok, my fault. I've forgot to mention that this patch was almost ready 
during Linaro meeting, but I didn't manage to post it that time. Of course 
it doesn't fulfill all the agreements from that discussion.

I was only unsure if we should care about the case where CMA is not enabled
for ARMv6+ or not. This patch was prepared in assumption that 
dma_alloc_coherent should work in both cases - with and without CMA.

Now I assume that for ARMv6+ the CMA should be enabled unconditionally.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
