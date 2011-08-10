Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED318900138
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 19:19:58 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1128794qwa.14
        for <linux-mm@kvack.org>; Wed, 10 Aug 2011 16:19:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312973240-32576-3-git-send-email-mgorman@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
	<1312973240-32576-3-git-send-email-mgorman@suse.de>
Date: Thu, 11 Aug 2011 08:19:56 +0900
Message-ID: <CAEwNFnCJB4jZTcOEVZmQ-AzHw3awscPv2nQoc_TW7qq6Lmkp+w@mail.gmail.com>
Subject: Re: [PATCH 2/7] mm: vmscan: Remove dead code related to lumpy reclaim
 waiting on pages under writeback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

On Wed, Aug 10, 2011 at 7:47 PM, Mel Gorman <mgorman@suse.de> wrote:
> Lumpy reclaim worked with two passes - the first which queued pages for
> IO and the second which waited on writeback. As direct reclaim can no
> longer write pages there is some dead code. This patch removes it but
> direct reclaim will continue to wait on pages under writeback while in
> synchronous reclaim mode.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
