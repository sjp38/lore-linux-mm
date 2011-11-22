Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFBE6B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 12:05:35 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so591623vcb.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:05:33 -0800 (PST)
Date: Wed, 23 Nov 2011 02:05:27 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/7] mm: check if we isolated a compound page during
 lumpy scan
Message-ID: <20111122170527.GC15253@barrios-laptop.redhat.com>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
 <1321900608-27687-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321900608-27687-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 21, 2011 at 06:36:44PM +0000, Mel Gorman wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Properly take into account if we isolated a compound page during the
> lumpy scan in reclaim and skip over the tail pages when encounted.
> This corrects the values given to the tracepoint for number of lumpy
> pages isolated and will avoid breaking the loop early if compound
> pages smaller than the requested allocation size are requested.
> 
> [mgorman@suse.de: Updated changelog]
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I would like to see removing lumpy part in vmscan.c.
It is complicated day by day. :(

Having said that, it looks good to me now.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
