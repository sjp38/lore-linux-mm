Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 83A516B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 05:07:52 -0500 (EST)
Date: Thu, 23 Dec 2010 10:06:42 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
Message-ID: <20101223100642.GD3636@n2100.arm.linux.org.uk>
References: <cover.1292443200.git.m.nazarewicz@samsung.com> <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Kyungmin Park <kmpark@infradead.org>
Cc: Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-arm-kernel@lists.infradead.org, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 06:30:57PM +0900, Kyungmin Park wrote:
> Hi Andrew,
> 
> any comments? what's the next step to merge it for 2.6.38 kernel. we
> want to use this feature at mainline kernel.

Has anyone addressed my issue with it that this is wide-open for
abuse by allocating large chunks of memory, and then remapping
them in some way with different attributes, thereby violating the
ARM architecture specification?

In other words, do we _actually_ have a use for this which doesn't
involve doing something like allocating 32MB of memory from it,
remapping it so that it's DMA coherent, and then performing DMA
on the resulting buffer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
