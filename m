Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E7D8F6B005C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 10:31:52 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv19 00/15] Contiguous Memory Allocator
Date: Thu, 26 Jan 2012 15:31:40 +0000
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201201261531.40551.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thursday 26 January 2012, Marek Szyprowski wrote:
> Welcome everyone!
> 
> Yes, that's true. This is yet another release of the Contiguous Memory
> Allocator patches. This version mainly includes code cleanups requested
> by Mel Gorman and a few minor bug fixes.

Hi Marek,

Thanks for keeping up this work! I really hope it works out for the
next merge window.

> TODO (optional):
> - implement support for contiguous memory areas placed in HIGHMEM zone
> - resolve issue with movable pages with pending io operations

Can you clarify these? I believe the contiguous memory areas in highmem
is something that should really be after the existing code is merged
into the upstream kernel and should better not be listed as TODO here.

I haven't followed the last two releases so closely. It seems that
in v17 the movable pages with pending i/o was still a major problem
but in v18 you added a solution. Is that right? What is still left
to be done here then?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
