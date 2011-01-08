Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E87F16B0088
	for <linux-mm@kvack.org>; Sat,  8 Jan 2011 17:22:21 -0500 (EST)
Date: Sat, 8 Jan 2011 23:22:11 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/7] fuse: Change remove_from_page_cache
Message-ID: <20110108222211.GC23189@cmpxchg.org>
References: <cover.1293031046.git.minchan.kim@gmail.com>
 <83e28e12e0c671777213e4a0d4fcc3b53c93ea1e.1293031046.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <83e28e12e0c671777213e4a0d4fcc3b53c93ea1e.1293031046.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 12:32:44AM +0900, Minchan Kim wrote:
> This patch series changes remove_from_page_cache's page ref counting
> rule. Page cache ref count is decreased in delete_from_page_cache.
> So we don't need decreasing page reference by caller.
> 
> Cc: Miklos Szeredi <miklos@szeredi.hu>
> Cc: fuse-devel@lists.sourceforge.net
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
