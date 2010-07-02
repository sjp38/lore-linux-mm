Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 315876B01AC
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:34:06 -0400 (EDT)
Date: Fri, 2 Jul 2010 12:33:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/14] Avoid overflowing of stack during page reclaim V3
Message-Id: <20100702123315.667c6eac.akpm@linux-foundation.org>
In-Reply-To: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 2010 12:34:34 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Here is V3 that depends again on flusher threads to do writeback in
> direct reclaim rather than stack switching which is not something I'm
> likely to get done before xfs/btrfs are ignoring writeback in mainline
> (phd sucking up time).

IMO, implemetning stack switching for this is not a good idea.  We
_already_ have a way of doing stack-switching.  It's called
"schedule()".

The only reason I can see for implementing an in-place stack switch
would be if schedule() is too expensive.  And if we were to see
excessive context-switch overheads in this code path (and we won't)
then we should get in there and try to reduce the contect switch rate
first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
