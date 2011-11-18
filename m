Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7488E6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 12:27:14 -0500 (EST)
Date: Fri, 18 Nov 2011 18:27:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/5] mm: compaction: Use synchronous compaction for
 /proc/sys/vm/compact_memory
Message-ID: <20111118172709.GA3579@redhat.com>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321635524-8586-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321635524-8586-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 18, 2011 at 04:58:41PM +0000, Mel Gorman wrote:
> When asynchronous compaction was introduced, the
> /proc/sys/vm/compact_memory handler should have been updated to always
> use synchronous compaction. This did not happen so this patch addresses
> it. The assumption is if a user writes to /proc/sys/vm/compact_memory,
> they are willing for that process to stall.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/compaction.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 237560e..615502b 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -666,6 +666,7 @@ static int compact_node(int nid)
>  			.nr_freepages = 0,
>  			.nr_migratepages = 0,
>  			.order = -1,
> +			.sync = true,
>  		};
>  
>  		zone = &pgdat->node_zones[zoneid];

Yep I noticed that yesterday too.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
