Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 42A6A6B0088
	for <linux-mm@kvack.org>; Sat,  8 Jan 2011 17:36:22 -0500 (EST)
Date: Sat, 8 Jan 2011 23:36:17 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 7/7] Change __remove_from_page_cache
Message-ID: <20110108223616.GH23189@cmpxchg.org>
References: <cover.1293031046.git.minchan.kim@gmail.com>
 <6661e5a219276b590365774d90ec8e300956a3ad.1293031047.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6661e5a219276b590365774d90ec8e300956a3ad.1293031047.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 12:32:49AM +0900, Minchan Kim wrote:
> Now we renamed remove_from_page_cache with delete_from_page_cache.
> As consistency of __remove_from_swap_cache and remove_from_swap_cache,
> We change internal page cache handling function name, too.
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
