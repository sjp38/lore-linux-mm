Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CF4426B0080
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 12:51:02 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so656878vcb.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:51:00 -0800 (PST)
Date: Wed, 23 Nov 2011 02:50:55 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 6/7] mm: page allocator: Limit when direct reclaim is
 used when compaction is deferred
Message-ID: <20111122175055.GE15253@barrios-laptop.redhat.com>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
 <1321900608-27687-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321900608-27687-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 21, 2011 at 06:36:47PM +0000, Mel Gorman wrote:
> If compaction is deferred, we enter direct reclaim to try reclaim the
> pages that way. For small high-orders, this has a reasonable chance
> of success. However, if the caller as specified __GFP_NO_KSWAPD to
> limit the disruption to the system, it makes more sense to fail the
> allocation rather than stall the caller in direct reclaim. This patch
> will skip direct reclaim if compaction is deferred and the caller
> specifies __GFP_NO_KSWAPD.
> 
> Async compaction only considers a subset of pages so it is possible for
> compaction to be deferred prematurely and not enter direct reclaim even
> in cases where it should. To compensate for this, this patch also defers
> compaction only if sync compaction failed.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan.kim@gmail.com>

It does make sense to me. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
