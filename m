Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B89D66B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 08:50:58 -0400 (EDT)
Date: Fri, 10 Jun 2011 13:52:17 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 02/10] lib: genalloc: Generic allocator improvements
Message-ID: <20110610135217.701a2fd2@lxorguk.ukuu.org.uk>
In-Reply-To: <000c01cc2769$02669b70$0733d250$%szyprowski@samsung.com>
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
	<1307699698-29369-3-git-send-email-m.szyprowski@samsung.com>
	<20110610122451.15af86d1@lxorguk.ukuu.org.uk>
	<000c01cc2769$02669b70$0733d250$%szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd
 Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>

> I plan to replace it with lib/bitmap.c bitmap_* based allocator (similar like
> it it is used by dma_declare_coherent_memory() and friends in
> drivers/base/dma-coherent.c). We need something really simple for CMA area
> management. 
> 
> IMHO allocate_resource and friends a bit too heavy here, but good to know 
> that such allocator also exists.

Not sure I'd class allocate_resource as heavyweight but providing it's
using something that already exists rather than inventing yet another
allocator.

This wants dealing with before it goes upstream though so the chaneges in
lib/*c etc never have to reach mainline and then get changed back.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
