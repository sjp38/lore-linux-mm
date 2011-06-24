Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 55BFE90023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 11:53:54 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 7/8] common: dma-mapping: change alloc/free_coherent method to more generic alloc/free_attrs
Date: Fri, 24 Jun 2011 17:53:49 +0200
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201106241753.49654.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

On Monday 20 June 2011, Marek Szyprowski wrote:
> mmap method is introduced to let the drivers create a user space mapping
> for a DMA buffer in generic, architecture independent way.

One more thing: please split out the mmap change into a separate patch.
I sense that there might be some objections to that, and it's better
to let people know about it early on than having them complain
later when that has already been merged.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
