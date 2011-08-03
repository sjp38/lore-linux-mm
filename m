Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36AEB900137
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 09:58:45 -0400 (EDT)
Date: Wed, 3 Aug 2011 14:58:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 8/8] mm: vmscan: Do not writeback filesystem pages from
 kswapd
Message-ID: <20110803135839.GL19099@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-9-git-send-email-mgorman@suse.de>
 <20110803113706.GF27199@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110803113706.GF27199@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, Aug 03, 2011 at 01:37:06PM +0200, Johannes Weiner wrote:
> On Thu, Jul 21, 2011 at 05:28:50PM +0100, Mel Gorman wrote:
> > Assuming that flusher threads will always write back dirty pages promptly
> > then it is always faster for reclaimers to wait for flushers. This patch
> > prevents kswapd writing back any filesystem pages.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Relying on the flushers may mean that every dirty page in the system
> has to be written back before the pages from the zone of interest are
> clean.
> 

Yes.

> De-facto we have only one mechanism to stay on top of the dirty pages
> from a per-zone perspective, and that is single-page writeout from
> reclaim.
> 

Yes.

> While we all agree that this sucks, we can not remove it unless we
> have a replacement that makes zones reclaimable in a reasonable time
> frame (or keep them reclaimable in the first place, what per-zone
> dirty limits attempt to do).
> 
> As such, please include
> 
> Nacked-by: Johannes Weiner <jweiner@redhat.com>

I've already dropped the patch. If I could, I would have signed this at
the time as

Signed-off-but-naking-it-anyway: Mel Gorman <mgorman@suse.de

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
