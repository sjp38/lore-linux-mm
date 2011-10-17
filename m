Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6827B6B002C
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 08:21:12 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LT700BXRMB87U40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 17 Oct 2011 13:21:08 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LT700I96MB8Q1@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 17 Oct 2011 13:21:08 +0100 (BST)
Date: Mon, 17 Oct 2011 14:21:07 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 2/9] mm: alloc_contig_freed_pages() added
In-reply-to: <20111014162933.d8fead58.akpm@linux-foundation.org>
Message-id: <01b201cc8cc7$3f6117d0$be234770$%szyprowski@samsung.com>
Content-language: pl
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-3-git-send-email-m.szyprowski@samsung.com>
 <20111014162933.d8fead58.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>

Hello Andrew,

Thanks for your comments. I will try to address them in the next round of
CMA patches.

On Saturday, October 15, 2011 1:30 AM Andrew Morton wrote:

(snipped)

> > +
> > +void free_contig_pages(unsigned long pfn, unsigned nr_pages)
> > +{
> > +	struct page *page = pfn_to_page(pfn);
> > +
> > +	while (nr_pages--) {
> > +		__free_page(page);
> > +		++pfn;
> > +		if (likely(zone_pfn_same_memmap(pfn - 1, pfn)))
> > +			++page;
> > +		else
> > +			page = pfn_to_page(pfn);
> > +	}
> > +}
> 
> You're sure these functions don't need EXPORT_SYMBOL()?  Maybe the
> design is that only DMA core calls into here (if so, that's good).

Drivers should not call it, it is intended to be used by low-level DMA
code. Do you think that a comment about missing EXPORT_SYMBOL is 
required?

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
