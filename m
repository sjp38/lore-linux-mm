Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 83DF06B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:25:14 -0400 (EDT)
Date: Tue, 21 Sep 2010 15:24:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 8/8] writeback: Do not sleep on the congestion queue if
 there are no congested BDIs or if significant congestion is not being
 encountered in the current zone
Message-Id: <20100921152433.6edd6a87.akpm@linux-foundation.org>
In-Reply-To: <20100921221008.GA16323@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie>
	<1284553671-31574-9-git-send-email-mel@csn.ul.ie>
	<20100916152810.cb074e9f.akpm@linux-foundation.org>
	<20100920095239.GE1998@csn.ul.ie>
	<20100921144413.abc45d2f.akpm@linux-foundation.org>
	<20100921221008.GA16323@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Sep 2010 23:10:08 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Tue, Sep 21, 2010 at 02:44:13PM -0700, Andrew Morton wrote:
> > On Mon, 20 Sep 2010 10:52:39 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > > > This patch tracks how many pages backed by a congested BDI were found during
> > > > > scanning. If all the dirty pages encountered on a list isolated from the
> > > > > LRU belong to a congested BDI, the zone is marked congested until the zone
> > > > > reaches the high watermark.
> > > > 
> > > > High watermark, or low watermark?
> > > > 
> > > 
> > > High watermark. The check is made by kswapd.
> > > 
> > > > The terms are rather ambiguous so let's avoid them.  Maybe "full"
> > > > watermark and "empty"?
> > > > 
> > > 
> > > Unfortunately they are ambiguous to me. I know what the high watermark
> > > is but not what the full or empty watermarks are.
> > 
> > Really.  So what's the "high" watermark? 
> 
> The high watermark is the point where kswapd goes back to sleep because
> enough pages have been reclaimed. It's a proxy measure for memory pressure.
> 
> > From the above text I'm
> > thinking that you mean the high watermark is when the queue has a small
> > number of requests and the low watermark is when the queue has a large
> > number of requests.
> > 
> 
> I was expecting "zone reaches the high watermark" was the clue that I was
> talking about zone watermarks and not an IO queue but it could be better.

It was more a rant about general terminology rather than one specific case.

> I will try and clarify. How about this as a replacement paragraph?

Works for me, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
