Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC186B0088
	for <linux-mm@kvack.org>; Sat,  8 Jan 2011 17:33:09 -0500 (EST)
Date: Sat, 8 Jan 2011 23:33:01 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/7] truncate: Change remove_from_page_cache
Message-ID: <20110108223300.GF23189@cmpxchg.org>
References: <cover.1293031046.git.minchan.kim@gmail.com>
 <fdafb3fb6ed32ec96f945fdbdd42bd6492d00cd7.1293031047.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fdafb3fb6ed32ec96f945fdbdd42bd6492d00cd7.1293031047.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 12:32:47AM +0900, Minchan Kim wrote:
> This patch series changes remove_from_page_cache's page ref counting
> rule. Page cache ref count is decreased in delete_from_page_cache.
> So we don't need decreasing page reference by caller.
> 
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: linux-mm@kvack.org
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
