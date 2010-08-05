Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 28ADB6B02AA
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 02:20:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o756KkHn004866
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Aug 2010 15:20:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A9E7745DE7A
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:20:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 38B8445DE4D
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:20:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE7D31DB8043
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:20:45 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 74A631DB8042
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:20:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Why PAGEOUT_IO_SYNC stalls for a long time
In-Reply-To: <20100804111005.GA17745@csn.ul.ie>
References: <20100801174229.4B08.A69D9226@jp.fujitsu.com> <20100804111005.GA17745@csn.ul.ie>
Message-Id: <20100805151630.31CF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Aug 2010 15:20:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Sun, Aug 01, 2010 at 05:47:08PM +0900, KOSAKI Motohiro wrote:
> > > > side note: page lock contention is very common case.
> > > > 
> > > > For case (8), I don't think sleeping is right way. get_page() is used in really various place of
> > > > our kernel. so we can't assume it's only temporary reference count increasing.
> > > 
> > > In what case is a munlocked pages reference count permanently increased and
> > > why is this not a memory leak?
> > 
> > V4L, audio, GEM and/or other multimedia driver?
> > 
> 
> Ok, that is quite likely. Have you made a start on a series related to
> lumpy reclaim? I was holding off making a start on such a thing while I
> reviewed the other writeback issues and travelling to MM Summit is going
> to delay things for me. If you haven't started when I get back, I'll
> make some sort of stab at it.

Yup, I posted them today. While my lite testing, they works intentionally. it mean
 - reduce low order reclaim latency
 - keep high successfull rate order-9 reclaim under heavy io workload

However, they obviously need more test. comment are welcome :)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
