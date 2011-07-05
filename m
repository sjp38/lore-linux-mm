Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD01290012A
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 08:28:43 -0400 (EDT)
Date: Tue, 5 Jul 2011 13:28:00 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv11 0/8] Contiguous Memory Allocator
Message-ID: <20110705122800.GC8286@n2100.arm.linux.org.uk>
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <201107051407.17249.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201107051407.17249.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Tue, Jul 05, 2011 at 02:07:17PM +0200, Arnd Bergmann wrote:
> On Tuesday 05 July 2011, Marek Szyprowski wrote:
> > This is yet another round of Contiguous Memory Allocator patches. I hope
> > that I've managed to resolve all the items discussed during the Memory
> > Management summit at Linaro Meeting in Budapest and pointed later on
> > mailing lists. The goal is to integrate it as tight as possible with
> > other kernel subsystems (like memory management and dma-mapping) and
> > finally merge to mainline.
> 
> You have certainly addressed all of my concerns, this looks really good now!
> 
> Andrew, can you add this to your -mm tree? What's your opinion on the
> current state, do you think this is ready for merging in 3.1 or would
> you want to have more reviews from core memory management people?

See my other mails.  It is not ready for mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
