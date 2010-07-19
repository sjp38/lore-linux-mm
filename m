Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4156B02A4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 10:19:38 -0400 (EDT)
Date: Mon, 19 Jul 2010 10:19:34 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in direct
 reclaim
Message-ID: <20100719141934.GB12510@infradead.org>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279545090-19169-5-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 02:11:26PM +0100, Mel Gorman wrote:
> As the call-chain for writing anonymous pages is not expected to be deep
> and they are not cleaned by flusher threads, anonymous pages are still
> written back in direct reclaim.

While it is not quite as deep as it skips the filesystem allocator and
extent mapping code it can still be quite deep for swap given that it
still has to traverse the whole I/O stack.  Probably not worth worrying
about now, but we need to keep an eye on it.

The patch looks fine to me anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
