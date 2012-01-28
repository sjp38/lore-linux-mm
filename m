Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 2F89D6B004D
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 19:26:26 -0500 (EST)
Date: Fri, 27 Jan 2012 16:26:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv19 00/15] Contiguous Memory Allocator
Message-Id: <20120127162624.40cba14e.akpm@linux-foundation.org>
In-Reply-To: <201201261531.40551.arnd@arndb.de>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
	<201201261531.40551.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, 26 Jan 2012 15:31:40 +0000
Arnd Bergmann <arnd@arndb.de> wrote:

> On Thursday 26 January 2012, Marek Szyprowski wrote:
> > Welcome everyone!
> > 
> > Yes, that's true. This is yet another release of the Contiguous Memory
> > Allocator patches. This version mainly includes code cleanups requested
> > by Mel Gorman and a few minor bug fixes.
> 
> Hi Marek,
> 
> Thanks for keeping up this work! I really hope it works out for the
> next merge window.

Someone please tell me when it's time to start paying attention
again ;)

These patches don't seem to have as many acked-bys and reviewed-bys as
I'd expect.  Given the scope and duration of this, it would be useful
to gather these up.  But please ensure they are real ones - people
sometimes like to ack things without showing much sign of having
actually read them.

Also there is the supreme tag: "Tested-by:.".  Ohad (at least) has been
testing the code.  Let's mention that.


The patches do seem to have been going round in ever-decreasing circles
lately and I think we have decided to merge them (yes?) so we may as well
get on and do that and sort out remaining issues in-tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
