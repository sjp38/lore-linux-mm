Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CE2956B01FD
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:10:22 -0400 (EDT)
Date: Mon, 14 Jun 2010 11:10:11 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/12] Avoid overflowing of stack during page reclaim V2
Message-ID: <20100614151011.GA24948@infradead.org>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 14, 2010 at 12:17:41PM +0100, Mel Gorman wrote:
> This is a merging of two series - the first of which reduces stack usage
> in page reclaim and the second which writes contiguous pages during reclaim
> and avoids writeback in direct reclaimers.

This stuff looks good to me from the filesystem POV.

You might want to throw in a follow on patch to remove the PF_MEMALLOC
checks from the various ->writepage methods.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
