Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 286546B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 07:37:21 -0400 (EDT)
Date: Wed, 3 Aug 2011 13:37:06 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 8/8] mm: vmscan: Do not writeback filesystem pages from
 kswapd
Message-ID: <20110803113706.GF27199@redhat.com>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-9-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311265730-5324-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 21, 2011 at 05:28:50PM +0100, Mel Gorman wrote:
> Assuming that flusher threads will always write back dirty pages promptly
> then it is always faster for reclaimers to wait for flushers. This patch
> prevents kswapd writing back any filesystem pages.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Relying on the flushers may mean that every dirty page in the system
has to be written back before the pages from the zone of interest are
clean.

De-facto we have only one mechanism to stay on top of the dirty pages
from a per-zone perspective, and that is single-page writeout from
reclaim.

While we all agree that this sucks, we can not remove it unless we
have a replacement that makes zones reclaimable in a reasonable time
frame (or keep them reclaimable in the first place, what per-zone
dirty limits attempt to do).

As such, please include

Nacked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
