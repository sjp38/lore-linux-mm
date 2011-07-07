Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 14C6D9000C3
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 08:09:22 -0400 (EDT)
Date: Thu, 7 Jul 2011 14:09:18 +0200
From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/8] ARM: dma-mapping: use
 asm-generic/dma-mapping-common.h
Message-ID: <20110707120918.GF7810@wantstofly.org>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <201106241736.43576.arnd@arndb.de>
 <000601cc34c4$430f91f0$c92eb5d0$%szyprowski@samsung.com>
 <201106271519.43581.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201106271519.43581.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

On Mon, Jun 27, 2011 at 03:19:43PM +0200, Arnd Bergmann wrote:

> > > I suppose for the majority of the cases, the overhead of the indirect
> > > function call is near-zero, compared to the overhead of the cache
> > > management operation, so it would only make a difference for coherent
> > > systems without an IOMMU. Do we care about micro-optimizing those?

FWIW, when I was hacking on ARM access point routing performance some
time ago, turning the L1/L2 cache maintenance operations into inline
functions (inlined into the ethernet driver) gave me a significant and
measurable performance boost.

Such things can remain product-specific hacks, though.


> > Even in coherent case, the overhead caused by additional function call
> > should have really negligible impact on drivers performance.
> 
> What about object code size? I guess since ixp23xx is the only platform
> that announces itself as coherent, we probably don't need to worry about
> it too much either. Lennert?

I don't think so.  ixp23xx isn't a very popular platform anymore either,
having been discontinued some time ago.


thanks,
Lennert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
