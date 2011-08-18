Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DAA51900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 04:28:28 -0400 (EDT)
Subject: RE: [PATCH 7/9] ARM: DMA: steal memory for DMA coherent mappings
From: Tixy <tixy@yxit.co.uk>
In-Reply-To: <009101cc5cde$6dfaa660$49eff320$%szyprowski@samsung.com>
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com>
	 <201108161626.26130.arnd@arndb.de>
	 <006b01cc5cb3$dac09fa0$9041dee0$%szyprowski@samsung.com>
	 <201108171428.44555.arnd@arndb.de>
	 <009101cc5cde$6dfaa660$49eff320$%szyprowski@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 18 Aug 2011 09:27:53 +0100
Message-ID: <1313656073.2254.23.camel@computer2>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Arnd Bergmann' <arnd@arndb.de>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Wed, 2011-08-17 at 15:06 +0200, Marek Szyprowski wrote:
[...]
> > > Maybe for the first version a static pool with reasonably small size
> > > (like 128KiB) will be more than enough? This size can be even board
> > > depended or changed with kernel command line for systems that really
> > > needs more memory.
> > 
> > For a first version that sounds good enough. Maybe we could use a fraction
> > of the CONSISTENT_DMA_SIZE as an estimate?
> 
> Ok, good. For the initial values I will probably use 1/8 of 
> CONSISTENT_DMA_SIZE for coherent allocations. Writecombine atomic allocations
> are extremely rare and rather ARM specific. 1/32 of CONSISTENT_DMA_SIZE should
> be more than enough for them.

For people who aren't aware, we have a patch to remove the define
CONSISTENT_DMA_SIZE and replace it with a runtime call to an
initialisation function [1]. I don't believe this fundamentally changes
anything being discussed though.

-- 
Tixy

[1] http://www.spinics.net/lists/arm-kernel/msg135589.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
