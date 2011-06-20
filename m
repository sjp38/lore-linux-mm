Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CE3309000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 11:07:00 -0400 (EDT)
Date: Mon, 20 Jun 2011 16:06:10 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 7/8] common: dma-mapping: change alloc/free_coherent
	method to more generic alloc/free_attrs
Message-ID: <20110620150610.GG26089@n2100.arm.linux.org.uk>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <1308556213-24970-8-git-send-email-m.szyprowski@samsung.com> <BANLkTikFdrOuXsLCfvyA_V+p7S_fd72dyQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikFdrOuXsLCfvyA_V+p7S_fd72dyQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>

On Mon, Jun 20, 2011 at 11:45:41PM +0900, KyongHo Cho wrote:
> I still don't agree with your idea that change alloc_coherent() with alloc().
> As I said before, we actually do not need dma_alloc_writecombine() anymore
> because it is not different from dma_alloc_coherent() in ARM.

Wrong - there is a difference.  For pre-ARMv6 CPUs, it returns memory
with different attributes from DMA coherent memory.

And we're not going to sweep away pre-ARMv6 CPUs any time soon.  So
you can't ignore dma_alloc_writecombine() which must remain to sanely
support framebuffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
