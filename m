Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2026006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 10:26:21 -0400 (EDT)
Date: Mon, 19 Jul 2010 10:26:17 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] vmscan: tracing: Update trace event to track if page
 reclaim IO is for anon or file pages
Message-ID: <20100719142617.GA24546@infradead.org>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-3-git-send-email-mel@csn.ul.ie>
 <20100719141501.GA12510@infradead.org>
 <20100719142436.GO13117@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100719142436.GO13117@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 03:24:36PM +0100, Mel Gorman wrote:
> Not a bad idea, I'll check it out. Thanks. The first flags would be;
> 
> RECLAIM_WB_ANON
> RECLAIM_WB_FILE
> 
> Does anyone have problems with the naming?

The names look fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
