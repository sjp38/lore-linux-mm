Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 061DC6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:38:01 -0500 (EST)
Date: Tue, 10 Feb 2009 11:37:32 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] introduce for_each_populated_zone() macro
Message-ID: <20090210103731.GA1740@cmpxchg.org>
References: <20090210162220.6FBC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090210162220.6FBC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 04:39:13PM +0900, KOSAKI Motohiro wrote:
> 
> Impact: cleanup
> 
> In almost case, for_each_zone() is used with populated_zone().
> It's because almost function doesn't need memoryless node information.
> Therefore, for_each_populated_zone() can help to make code simplify.
> 
> This patch doesn't have any functional change.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/mmzone.h  |   11 +++++++++++
>  kernel/power/snapshot.c |    9 +++------
>  kernel/power/swsusp.c   |   17 ++++++++---------
>  mm/page_alloc.c         |   26 +++++---------------------
>  mm/vmscan.c             |    6 +-----
>  mm/vmstat.c             |   11 ++---------
>  6 files changed, 30 insertions(+), 50 deletions(-)

Nice!

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
