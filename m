Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 232396B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 02:48:31 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M2A003RIYW98610@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 11 Apr 2012 07:48:09 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2A0081OYWSQI@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 11 Apr 2012 07:48:29 +0100 (BST)
Date: Wed, 11 Apr 2012 08:48:24 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv24 00/16] Contiguous Memory Allocator
In-reply-to: 
 <CA+K6fF5TbhYX_XYXL33h5s8cnSogSna4Cq2-vM4MfX4igSyozg@mail.gmail.com>
Message-id: <00c201cd17af$17a3aa50$46eafef0$%szyprowski@samsung.com>
Content-language: pl
References: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
 <alpine.DEB.2.00.1204101528390.9354@kernel.research.nokia.com>
 <CA+K6fF5TbhYX_XYXL33h5s8cnSogSna4Cq2-vM4MfX4igSyozg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Sandeep Patil' <psandeep.s@gmail.com>, 'Aaro Koskinen' <aaro.koskinen@nokia.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Ohad Ben-Cohen' <ohad@wizery.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Rob Clark' <rob.clark@linaro.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

Hi,

On Tuesday, April 10, 2012 7:20 PM Sandeep Patil wrote:

> >> This is (yet another) update of CMA patches.
> >
> >
> > How well CMA is supposed to work if you have mlocked processes? I've
> > been testing these patches, and noticed that by creating a small mlocked
> > process you start to get plenty of test_pages_isolated() failure warnings,
> > and bigger allocations will always fail.
> 
> CMIIW, I think mlocked pages are never migrated. The reason is because
> __isolate_lru_pages() does not isolate Unevictable pages right now.
> 
> Minchan added support to allow this but the patch was dropped.
> 
> See the discussion at : https://lkml.org/lkml/2011/8/29/295

Right, we are aware of this limitation. We are working on solving it but we didn't 
consider it a blocker for the core CMA patches. Such issues can be easily fixed with 
the incremental patches.

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
