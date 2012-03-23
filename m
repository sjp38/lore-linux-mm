Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 290476B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 06:24:40 -0400 (EDT)
Date: Fri, 23 Mar 2012 10:24:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: fix testorder interaction between two kswapd patches
Message-ID: <20120323102436.GJ1007@csn.ul.ie>
References: <alpine.LSU.2.00.1203230254110.31362@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1203230254110.31362@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Fri, Mar 23, 2012 at 02:57:31AM -0700, Hugh Dickins wrote:
> Adjusting cc715d99e529 "mm: vmscan: forcibly scan highmem if there are
> too many buffer_heads pinning highmem" for -stable reveals that it was
> slightly wrong once on top of fe2c2a106663 "vmscan: reclaim at order 0
> when compaction is enabled", which specifically adds testorder for the
> zone_watermark_ok_safe() test.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
