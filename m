Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 162AC6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 08:22:12 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LMK008R4QCXZC@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 10 Jun 2011 13:22:09 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMK007GOQCWZU@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Jun 2011 13:22:08 +0100 (BST)
Date: Fri, 10 Jun 2011 14:22:05 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 02/10] lib: genalloc: Generic allocator improvements
In-reply-to: <20110610122451.15af86d1@lxorguk.ukuu.org.uk>
Message-id: <000c01cc2769$02669b70$0733d250$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <1307699698-29369-3-git-send-email-m.szyprowski@samsung.com>
 <20110610122451.15af86d1@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Alan Cox' <alan@lxorguk.ukuu.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>

Hello,

On Friday, June 10, 2011 1:25 PM Alan Cox wrote:

> I am curious about one thing
> 
> Why do we need this allocator. Why not use allocate_resource and friends.
> The kernel generic resource handler already handles object alignment and
> subranges. It just seems to be a surplus allocator that could perhaps be
> mostly removed by using the kernel resource allocator we already have ?

genalloc was used mainly for historical reasons (in the earlier version we
were looking for direct replacement for first fit allocator).

I plan to replace it with lib/bitmap.c bitmap_* based allocator (similar like
it it is used by dma_declare_coherent_memory() and friends in
drivers/base/dma-coherent.c). We need something really simple for CMA area
management. 

IMHO allocate_resource and friends a bit too heavy here, but good to know 
that such allocator also exists.

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
