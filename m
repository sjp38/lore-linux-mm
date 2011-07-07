Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4F49000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 03:37:55 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv11 0/8] Contiguous Memory Allocator
Date: Thu, 7 Jul 2011 09:36:34 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <201107051407.17249.arnd@arndb.de> <20110706151112.5c619431.akpm@linux-foundation.org>
In-Reply-To: <20110706151112.5c619431.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201107070936.34469.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-media@vger.kernel.org

On Thursday 07 July 2011 00:11:12 Andrew Morton wrote:
> I could review it and put it in there on a preliminary basis for some
> runtime testing.  But the question in my mind is how different will the
> code be after the problems which rmk has identified have been fixed?
> 
> If "not very different" then that effort and testing will have been
> worthwhile.
> 
> If "very different" or "unworkable" then it was all for naught.
> 
> So.  Do we have a feeling for the magnitude of the changes which will
> be needed to fix these things up?

As far as I can tell, the changes that we still need are mostly in the 
ARM specific portion of the series. All architectures that have cache
coherent DMA by default (most of the other interesting ones) can just
call dma_alloc_from_contiguous() from their dma_alloc_coherent()
function without having to do extra work.

It's possible that there will be small changes to simplify to the
first six patches in order to simplify the ARM port, but I expect
them to stay basically as they are, unless someone complains about
them.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
