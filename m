Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 9B7506B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 08:23:02 -0400 (EDT)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2S002VA2C619@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 20 Apr 2012 13:21:42 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2S0093E2EBSZ@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Apr 2012 13:23:00 +0100 (BST)
Date: Fri, 20 Apr 2012 14:22:55 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv24 00/16] Contiguous Memory Allocator
In-reply-to: <20120419124044.632bfa49.akpm@linux-foundation.org>
Message-id: <03b201cd1ef0$50ca9350$f25fb9f0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
 <20120419124044.632bfa49.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>, 'Rob Clark' <rob.clark@linaro.org>, 'Ohad Ben-Cohen' <ohad@wizery.com>, 'Sandeep Patil' <psandeep.s@gmail.com>

Hi Andrew,

On Thursday, April 19, 2012 9:41 PM Andrew Morton wrote:

> On Tue, 03 Apr 2012 16:10:05 +0200
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> 
> > This is (yet another) update of CMA patches.
> 
> Looks OK to me.  It's a lot of code.
> 
> Please move it into linux-next, and if all is well, ask Linus to pull
> the tree into 3.5-rc1.  Please be sure to cc me on that email.

Ok, thanks! Is it possible to get your acked-by or reviewed-by tag? It
might help a bit to get the pull request accepted by Linus. :)

> I suggest that you include additional patches which enable CMA as much
> as possible on as many architectures as possible so that it gets
> maximum coverage testing in linux-next.  Remove those Kconfig patches
> when merging upstream.
> 
> All this code will probably mess up my tree, but I'll work that out.
> It would be more awkward if the CMA code were to later disappear from
> linux-next or were not merged into 3.5-rc1.  Let's avoid that.

I've put the patches on my dma-mapping-next branch and we will see the
result (and/or complaints) on Monday.

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
