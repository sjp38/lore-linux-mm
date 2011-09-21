Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F55E9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 09:47:13 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=utf-8
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LRV006M9KYNX140@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Sep 2011 14:47:11 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LRV00KETKYM0C@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Sep 2011 14:47:11 +0100 (BST)
Date: Wed, 21 Sep 2011 15:47:05 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 7/8] ARM: integrate CMA with DMA-mapping subsystem
In-reply-to: 
 <CAMjpGUch=ogFQwBLqOukKVnyh60600jw5tMq-KYeNGSZ2PLQpA@mail.gmail.com>
Message-id: <001a01cc7864$f2c98ea0$d85cabe0$%szyprowski@samsung.com>
Content-language: pl
References: <1313764064-9747-1-git-send-email-m.szyprowski@samsung.com>
 <1313764064-9747-8-git-send-email-m.szyprowski@samsung.com>
 <CAMjpGUch=ogFQwBLqOukKVnyh60600jw5tMq-KYeNGSZ2PLQpA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Frysinger' <vapier.adi@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Thursday, September 08, 2011 7:27 PM Mike Frysinger wrote:

> On Fri, Aug 19, 2011 at 10:27, Marek Szyprowski wrote:
> >  arch/arm/include/asm/device.h         |    3 +
> >  arch/arm/include/asm/dma-contiguous.h |   33 +++
> 
> seems like these would be good asm-generic/ additions rather than arm

Only some of them can be really moved to asm-generic imho. The following
lines are definitely architecture specific:

void dma_contiguous_early_fixup(phys_addr_t base, unsigned long size);

Some other archs might define empty fixup function. Right now only ARM 
architecture is the real client of the CMA. IMHO if any other arch stats
using CMA, some of the CMA definitions can be then moved to asm-generic.
Right now I wanted to keep it as simple as possible.

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
