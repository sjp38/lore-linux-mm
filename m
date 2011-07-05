Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB64900125
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 07:30:31 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/8] mm: alloc_contig_freed_pages() added
Date: Tue, 5 Jul 2011 13:30:07 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <1309851710-3828-3-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1309851710-3828-3-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201107051330.07443.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Tuesday 05 July 2011, Marek Szyprowski wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This commit introduces alloc_contig_freed_pages() function
> which allocates (ie. removes from buddy system) free pages
> in range.  Caller has to guarantee that all pages in range
> are in buddy system.
> 
> Along with this function, a free_contig_pages() function is
> provided which frees all (or a subset of) pages allocated
> with alloc_contig_free_pages().
> 
> Michal Nazarewicz has modified the function to make it easier
> to allocate not MAX_ORDER_NR_PAGES aligned pages by making it
> return pfn of one-past-the-last allocated page.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
