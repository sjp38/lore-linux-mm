Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1D86B017E
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 10:41:55 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LNG00CUKE5TI700@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jun 2011 15:41:53 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNG0024KE5S32@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jun 2011 15:41:52 +0100 (BST)
Date: Mon, 27 Jun 2011 16:41:48 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 7/8] common: dma-mapping: change alloc/free_coherent method
 to more generic alloc/free_attrs
In-reply-to: <201106241753.49654.arnd@arndb.de>
Message-id: <000b01cc34d8$58856820$09903860$%szyprowski@samsung.com>
Content-language: pl
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
 <201106241753.49654.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

Hello,

On Friday, June 24, 2011 5:54 PM Arnd Bergmann wrote:

> On Monday 20 June 2011, Marek Szyprowski wrote:
> > mmap method is introduced to let the drivers create a user space mapping
> > for a DMA buffer in generic, architecture independent way.
> 
> One more thing: please split out the mmap change into a separate patch.

Ok, no problem.

> I sense that there might be some objections to that, and it's better
> to let people know about it early on than having them complain
> later when that has already been merged.

Ok, I will also prepare much more detailed description for mmap patch.

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
