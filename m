Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 331146B0169
	for <linux-mm@kvack.org>; Sun, 14 Aug 2011 03:52:43 -0400 (EDT)
Date: Sun, 14 Aug 2011 08:52:05 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 7/9] ARM: DMA: steal memory for DMA coherent mappings
Message-ID: <20110814075205.GA4986@n2100.arm.linux.org.uk>
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com> <1313146711-1767-8-git-send-email-m.szyprowski@samsung.com> <201108121453.05898.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201108121453.05898.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Fri, Aug 12, 2011 at 02:53:05PM +0200, Arnd Bergmann wrote:
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
> 
> I thought that our discussion ended with the plan to use this only
> for ARMv6+ (which has a problem with double mapping) but not on ARMv5
> and below (which don't have this problem but might need dmabounce).

I thought we'd decided to have a pool of available CMA memory on ARMv6K
to satisfy atomic allocations, which can grow and shrink in size, rather
than setting aside a fixed amount of contiguous system memory.

ARMv6 and ARMv7+ could use CMA directly, and <= ARMv5 can use the existing
allocation method.

Has something changed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
