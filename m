Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D9D316B01A2
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 05:14:42 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LT10046ITOGDC20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Oct 2011 10:14:40 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LT100AHJTOFYM@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Oct 2011 10:14:40 +0100 (BST)
Date: Fri, 14 Oct 2011 11:14:25 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 8/9] ARM: integrate CMA with DMA-mapping
 subsystem
In-reply-to: <4E97BB8E.3060204@gmail.com>
Message-id: <013701cc8a51$ab1a3fb0$014ebf10$%szyprowski@samsung.com>
Content-language: pl
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-10-git-send-email-m.szyprowski@samsung.com>
 <4E97BB8E.3060204@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Subash Patel' <subashrp@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

Hello,

On Friday, October 14, 2011 6:33 AM Subash Patel wrote:

> Hi Marek,
> 
> As informed to you in private over IRC, below piece of code broke during
> booting EXYNOS4:SMDKV310 with ZONE_DMA enabled.

Right, I missed the fact that ZONE_DMA can be enabled but the machine does not
provide specific zone size. I will fix this in the next version. Thanks for 
pointing this bug!

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
