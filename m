Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 46D5A6B13F4
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 13:10:46 -0500 (EST)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZ600F33VTWW4@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 10 Feb 2012 18:10:44 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ600M1EVTWE2@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 18:10:44 +0000 (GMT)
Date: Fri, 10 Feb 2012 19:10:40 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv19 00/15] Contiguous Memory Allocator
In-reply-to: <20120127162624.40cba14e.akpm@linux-foundation.org>
Message-id: <00d901cce81f$4c3edc40$e4bc94c0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <201201261531.40551.arnd@arndb.de>
 <20120127162624.40cba14e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>, 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>

Hi Andrew,

On Saturday, January 28, 2012 1:26 AM Andrew Morton wrote:

> These patches don't seem to have as many acked-bys and reviewed-bys as
> I'd expect.  Given the scope and duration of this, it would be useful
> to gather these up.  But please ensure they are real ones - people
> sometimes like to ack things without showing much sign of having
> actually read them.
> 
> Also there is the supreme tag: "Tested-by:.".  Ohad (at least) has been
> testing the code.  Let's mention that.
> 
> 
> The patches do seem to have been going round in ever-decreasing circles
> lately and I think we have decided to merge them (yes?) so we may as well
> get on and do that and sort out remaining issues in-tree.

It looks that the CMA patch series reached the final version - I've just 
posted version 21 a few minutes ago. Most of the patches got acks from either 
Mel or Arnd and the remaining few needs only minor tweaking, but they affect
only CMA users, which we hope to fix once the series is merged. That's why I
would like to ask You to merge these patches to Your tree and finally give
them a try in linux-next kernel.

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
