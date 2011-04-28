Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 164BF6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 06:50:32 -0400 (EDT)
Date: Thu, 28 Apr 2011 11:50:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC 5/8] compaction: remove active list counting
Message-ID: <20110428105027.GT4658@suse.de>
References: <cover.1303833415.git.minchan.kim@gmail.com>
 <2b79bbf9ddceb73624f49bbe9477126147d875fd.1303833417.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2b79bbf9ddceb73624f49bbe9477126147d875fd.1303833417.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 01:25:22AM +0900, Minchan Kim wrote:
> acct_isolated of compaction uses page_lru_base_type which returns only
> base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTIVE_FILE.
> So it's pointless to add lru[LRU_ACTIVE_[ANON|FILE]] to get sum.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

hmm, isolate_migratepages() is doing a linear scan of PFNs and is
calling __isolate_lru_page(..ISOLATE_BOTH..). Using page_lru_base_type
happens to work because we're only interested in the number of isolated
pages and your patch still covers that. Using page_lru might be more
accurate in terms of accountancy but does not seem necessary.

Adding a comment explaining why we account for it as inactive and why
that's ok would be nice although I admit this is something I should have
done when acct_isolated() was introduced.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
