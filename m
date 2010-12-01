Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 584566B0085
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 05:32:20 -0500 (EST)
Date: Wed, 1 Dec 2010 11:31:54 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] mm: compaction: Perform a faster migration scan when
 migrating asynchronously
Message-ID: <20101201103154.GO15564@cmpxchg.org>
References: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
 <1290440635-30071-7-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290440635-30071-7-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 03:43:54PM +0000, Mel Gorman wrote:
> try_to_compact_pages() is initially called to only migrate pages asychronously
> and kswapd always compacts asynchronously. Both are being optimistic so it
> is important to complete the work as quickly as possible to minimise stalls.
> 
> This patch alters the scanner when asynchronous to only consider
> MIGRATE_MOVABLE pageblocks as migration candidates. This reduces stalls
> when allocating huge pages while not impairing allocation success rates as
> a full scan will be performed if necessary after direct reclaim.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
