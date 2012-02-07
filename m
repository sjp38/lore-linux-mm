Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 86C5B6B13F0
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 04:48:51 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZ000KVLOLDB1@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 07 Feb 2012 09:48:49 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ0004ASOLDGA@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Feb 2012 09:48:49 +0000 (GMT)
Date: Tue, 07 Feb 2012 10:48:48 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: Contiguous Memory Allocator on HIGHMEM
In-reply-to: <4F30E97F.9000409@ingenic.cn>
Message-id: <003601cce57d$b0df2af0$129d80d0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <4F30E97F.9000409@ingenic.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'cp.zou'" <cpzou@ingenic.cn>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mel@csn.ul.ie>

Hello,

On Tuesday, February 07, 2012 10:06 AM cp.zou wrote:

> Hello everyone!
> 
> I'm recently learning CMA, and I want to implement support for
> contiguous memory areas placed in HIGHMEM zone,do you have any suggestions?

CMA memory management core (migration and allocation of pages) should support
areas placed in HIGHMEM without any additional works. The main limitation is
in the DMA-mapping framework. Right now it makes certain assumptions about page
mappings to simplify allocation process. You need to add support for dynamic
mappings there. 

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
