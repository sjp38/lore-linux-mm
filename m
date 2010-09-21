Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1946B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 17:44:50 -0400 (EDT)
Date: Tue, 21 Sep 2010 14:44:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 8/8] writeback: Do not sleep on the congestion queue if
 there are no congested BDIs or if significant congestion is not being
 encountered in the current zone
Message-Id: <20100921144413.abc45d2f.akpm@linux-foundation.org>
In-Reply-To: <20100920095239.GE1998@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie>
	<1284553671-31574-9-git-send-email-mel@csn.ul.ie>
	<20100916152810.cb074e9f.akpm@linux-foundation.org>
	<20100920095239.GE1998@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Sep 2010 10:52:39 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> > > This patch tracks how many pages backed by a congested BDI were found during
> > > scanning. If all the dirty pages encountered on a list isolated from the
> > > LRU belong to a congested BDI, the zone is marked congested until the zone
> > > reaches the high watermark.
> > 
> > High watermark, or low watermark?
> > 
> 
> High watermark. The check is made by kswapd.
> 
> > The terms are rather ambiguous so let's avoid them.  Maybe "full"
> > watermark and "empty"?
> > 
> 
> Unfortunately they are ambiguous to me. I know what the high watermark
> is but not what the full or empty watermarks are.

Really.  So what's the "high" watermark?  From the above text I'm
thinking that you mean the high watermark is when the queue has a small
number of requests and the low watermark is when the queue has a large
number of requests.

I'd have thought that this is backwards: the "high" watermark is when
the queue has a large (ie: high) number of requests.

A problem.  How do we fix it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
