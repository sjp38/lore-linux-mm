Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A08836B004A
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 11:47:35 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LNX0004G578L8@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 06 Jul 2011 16:47:33 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNX00FJ0577DP@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jul 2011 16:47:31 +0100 (BST)
Date: Wed, 06 Jul 2011 17:47:27 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 6/8] drivers: add Contiguous Memory Allocator
In-reply-to: <20110706153704.GF8286@n2100.arm.linux.org.uk>
Message-id: <007801cc3bf4$01fdefe0$05f9cfa0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
 <20110705113345.GA8286@n2100.arm.linux.org.uk>
 <006301cc3be4$daab1850$900148f0$%szyprowski@samsung.com>
 <201107061609.29996.arnd@arndb.de>
 <007101cc3bec$dfbba8c0$9f32fa40$%szyprowski@samsung.com>
 <20110706153704.GF8286@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Arnd Bergmann' <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

Hello,

On Wednesday, July 06, 2011 5:37 PM Russell King - ARM Linux wrote:

> On Wed, Jul 06, 2011 at 04:56:23PM +0200, Marek Szyprowski wrote:
> > This will not solve our problems. We need CMA also to create at least one
> > device private area that for sure will be in low memory (video codec).
> 
> You make these statements but you don't say why.  Can you please
> explain why the video codec needs low memory - does it have a
> restricted number of memory address bits which it can manipulate?

Nope, it only needs to put some type of memory buffers in first bank 
(effectively in 30000000-34ffffff area) and the others in the second bank
(40000000-57ffffff area). The values are given for Samsung GONI board.

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
