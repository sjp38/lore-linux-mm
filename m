Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5DCF06B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 19:27:08 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7VNR5KW031970
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Sep 2010 08:27:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8759E45DE51
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:27:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 667E145DE4E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:27:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FFFD1DB8038
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:27:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D72F1DB8040
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:27:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] mm: page allocator: Update free page counters after pages are placed on the free list
In-Reply-To: <1283276257-1793-2-git-send-email-mel@csn.ul.ie>
References: <1283276257-1793-1-git-send-email-mel@csn.ul.ie> <1283276257-1793-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20100901082634.971C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Sep 2010 08:27:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> When allocating a page, the system uses NR_FREE_PAGES counters to determine
> if watermarks would remain intact after the allocation was made. This
> check is made without interrupts disabled or the zone lock held and so is
> race-prone by nature. Unfortunately, when pages are being freed in batch,
> the counters are updated before the pages are added on the list. During this
> window, the counters are misleading as the pages do not exist yet. When
> under significant pressure on systems with large numbers of CPUs, it's
> possible for processes to make progress even though they should have been
> stalled. This is particularly problematic if a number of the processes are
> using GFP_ATOMIC as the min watermark can be accidentally breached and in
> extreme cases, the system can livelock.
> 
> This patch updates the counters after the pages have been added to the
> list. This makes the allocator more cautious with respect to preserving
> the watermarks and mitigates livelock possibilities.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
