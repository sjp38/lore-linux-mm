Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7C69000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:40:28 -0400 (EDT)
Date: Mon, 20 Jun 2011 15:40:12 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 4/8] ARM: dma-mapping: implement dma sg methods on top
	of generic dma ops
Message-ID: <20110620144012.GE26089@n2100.arm.linux.org.uk>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <1308556213-24970-5-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308556213-24970-5-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>

On Mon, Jun 20, 2011 at 09:50:09AM +0200, Marek Szyprowski wrote:
> This patch converts all dma_sg methods to be generic (independent of the
> current DMA mapping implementation for ARM architecture). All dma sg
> operations are now implemented on top of respective
> dma_map_page/dma_sync_single_for* operations from dma_map_ops structure.

No.  We really don't want to do this.  If we want to move the dsb() out
of the mapping functions (which I have a patch for) to avoid doing a
dsb() on each and every sg segment, then we must not use the generic
stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
