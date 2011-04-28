Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B3B6B6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 06:31:31 -0400 (EDT)
Date: Thu, 28 Apr 2011 11:31:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC 2/8] compaction: make isolate_lru_page with filter aware
Message-ID: <20110428103126.GR4658@suse.de>
References: <cover.1303833415.git.minchan.kim@gmail.com>
 <4dc5e63cfc8672426336e43dea29057d5bb6e863.1303833417.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4dc5e63cfc8672426336e43dea29057d5bb6e863.1303833417.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 01:25:19AM +0900, Minchan Kim wrote:
> In async mode, compaction doesn't migrate dirty or writeback pages.
> So, it's meaningless to pick the page and re-add it to lru list.
> 
> Of course, when we isolate the page in compaction, the page might
> be dirty or writeback but when we try to migrate the page, the page
> would be not dirty, writeback. So it could be migrated. But it's
> very unlikely as isolate and migration cycle is much faster than
> writeout.
> 
> So, this patch helps cpu and prevent unnecessary LRU churning.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
