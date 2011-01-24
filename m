Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2B12C6B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 12:10:25 -0500 (EST)
Message-ID: <4D3DB234.4050703@redhat.com>
Date: Mon, 24 Jan 2011 12:09:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: clear pages_scanned only if draining a pcp adds pages
 to the buddy allocator
References: <alpine.DEB.2.00.1101231457130.966@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1101231457130.966@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/23/2011 05:58 PM, David Rientjes wrote:
> 0e093d99763e (writeback: do not sleep on the congestion queue if there
> are no congested BDIs or if significant congestion is not being
> encountered in the current zone) uncovered a livelock in the page
> allocator that resulted in tasks infinitely looping trying to find memory
> and kswapd running at 100% cpu.
>
> The issue occurs because drain_all_pages() is called immediately
> following direct reclaim when no memory is freed and try_to_free_pages()
> returns non-zero because all zones in the zonelist do not have their
> all_unreclaimable flag set.

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
