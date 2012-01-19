Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id E561E6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 02:36:45 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LY1006M1BT8E720@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Jan 2012 07:36:44 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LY100ADMBT76T@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Jan 2012 07:36:44 +0000 (GMT)
Date: Thu, 19 Jan 2012 08:36:38 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 04/11] mm: page_alloc: introduce
 alloc_contig_range()
In-reply-to: 
 <CA+K6fF6A1kPUW-2Mw5+W_QaTuLfU0_m0aMYRLOg98mFKwZOhtQ@mail.gmail.com>
Message-id: <002901ccd67d$1465e560$3d31b020$%szyprowski@samsung.com>
Content-language: pl
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-5-git-send-email-m.szyprowski@samsung.com>
 <CA+K6fF6A1kPUW-2Mw5+W_QaTuLfU0_m0aMYRLOg98mFKwZOhtQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'sandeep patil' <psandeep.s@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

Hello,

On Tuesday, January 17, 2012 10:54 PM sandeep patil wrote:

> I am running a CMA test where I keep allocating from a CMA region as long
> as the allocation fails due to lack of space.
> 
> However, I am seeing failures much before I expect them to happen.
> When the allocation fails, I see a warning coming from __alloc_contig_range(),
> because test_pages_isolated() returned "true".
> 
> The new retry code does try a new range and eventually succeeds.

(snipped)

> From the log it looks like the warning showed up because page->private
> is set to MIGRATE_CMA instead of MIGRATE_ISOLATED.

> I've also had a test case where it failed because (page_count() != 0)

This means that the page is temporarily used by someone else (like for example
io subsystem or a driver).

> Have you or anyone else seen this during the CMA testing?

Yes, we observed such issues and we are also working on fixing them. However 
we gave higher priority to get the basic CMA patches merged to mainline. Once
this happen the above issues can be fixed incrementally.

> Also, could this be because we are finding a page within (start, end)
> that actually belongs
> to a higher order Buddy block ?

No, such pages should be correctly handled.

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
