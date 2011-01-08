Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C459E6B0088
	for <linux-mm@kvack.org>; Sat,  8 Jan 2011 17:35:48 -0500 (EST)
Date: Sat, 8 Jan 2011 23:35:43 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] Good bye remove_from_page_cache
Message-ID: <20110108223543.GG23189@cmpxchg.org>
References: <cover.1293031046.git.minchan.kim@gmail.com>
 <958620cb6a73a5633619d7d4a9793bc284260684.1293031047.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <958620cb6a73a5633619d7d4a9793bc284260684.1293031047.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 12:32:48AM +0900, Minchan Kim wrote:
> Now delete_from_page_cache replaces remove_from_page_cache.
> So we remove remove_from_page_cache so fs or something out of
> mainline will notice it when compile time and can fix it.
> 
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
