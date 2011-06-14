Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD226B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 14:30:40 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
Date: Tue, 14 Jun 2011 20:30:07 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <201106141803.00876.arnd@arndb.de> <op.vw2r3xrj3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <op.vw2r3xrj3l0zgt@mnazarewicz-glaptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201106142030.07549.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

On Tuesday 14 June 2011 18:58:35 Michal Nazarewicz wrote:
> On Tue, 14 Jun 2011 18:03:00 +0200, Arnd Bergmann wrote:
> > For all I know, that is something that is only true for a few very  
> > special Samsung devices,
> 
> Maybe.  I'm just answering your question. :)
> 
> Ah yes, I forgot that separate regions for different purposes could
> decrease fragmentation.

That is indeed a good point, but having a good allocator algorithm
could also solve this. I don't know too much about these allocation
algorithms, but there are probably multiple working approaches to this.

> > I would suggest going forward without having multiple regions:
> 
> Is having support for multiple regions a bad thing?  Frankly,
> removing this support will change code from reading context passed
> as argument to code reading context from global variable.  Nothing
> is gained; functionality is lost.

What is bad IMHO is making them the default, which forces the board
code to care about memory management details. I would much prefer
to have contiguous allocation parameters tuned automatically to just
work on most boards before we add ways to do board-specific hacks.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
