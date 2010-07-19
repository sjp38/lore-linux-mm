Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A38CA6006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 10:21:48 -0400 (EDT)
Date: Mon, 19 Jul 2010 10:21:45 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100719142145.GD12510@infradead.org>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 02:11:29PM +0100, Mel Gorman wrote:
> From: Wu Fengguang <fengguang.wu@intel.com>
> 
> A background flush work may run for ever. So it's reasonable for it to
> mimic the kupdate behavior of syncing old/expired inodes first.
> 
> This behavior also makes sense from the perspective of page reclaim.
> File pages are added to the inactive list and promoted if referenced
> after one recycling. If not referenced, it's very easy for pages to be
> cleaned from reclaim context which is inefficient in terms of IO. If
> background flush is cleaning pages, it's best it cleans old pages to
> help minimise IO from reclaim.

Yes, we absolutely do this.  Wu, do you have an improved version of the
pending or should we put it in this version for now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
