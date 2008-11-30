Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail2.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAU6UqB3022735
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 30 Nov 2008 15:30:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ED402AEA81
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 15:30:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EEB31EF082
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 15:30:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CFE61DB803E
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 15:30:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BB1491DB803A
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 15:30:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max pages
In-Reply-To: <49316CAF.2010006@redhat.com>
References: <20081129164624.8134.KOSAKI.MOTOHIRO@jp.fujitsu.com> <49316CAF.2010006@redhat.com>
Message-Id: <20081130150849.8140.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 30 Nov 2008 15:30:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

> Reclaiming is very easy when the workload is just page cache,
> because the application will be throttled when too many page
> cache pages are dirty.
> 
> When using mmap or memory hogs writing to swap, applications
> will not be throttled by the "too many dirty pages" logic,
> but may instead end up being throttled in the direct reclaim
> path instead.
> 
> At that point direct reclaim may become a lot more common,
> making the imbalance more significant.

fair enough.


> I'll run a few tests.

Great.
I'm looking for your mail :)


> > Andrew, I hope add this mesurement result to rvr bailing out patch description too.
> 
> So far the performance numbers you have measured are very
> encouraging and do indeed suggest that the priority==DEF_PRIORITY
> thing does not make a difference.

thank you.

I believe reclaim latency reducing doesn't only improve hpc, but also
improve several multimedia and desktop application.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
