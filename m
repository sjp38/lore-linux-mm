Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F77E8D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 06:34:22 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C973A3EE0AE
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:34:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF96D45DE5C
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:34:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 92DD645DE56
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:34:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 835A71DB804D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:34:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F3CB1DB8046
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:34:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm, mem-hotplug: update pcp->stat_threshold when memory hotplug occur
In-Reply-To: <BANLkTinORojJgOdHeRMLMkKGc-Jitu-unQ@mail.gmail.com>
References: <20110412183010.B52A.A69D9226@jp.fujitsu.com> <BANLkTinORojJgOdHeRMLMkKGc-Jitu-unQ@mail.gmail.com>
Message-Id: <20110412193407.B52F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 12 Apr 2011 19:34:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

> > No good stat_threshold might makes performance hurt.
> 
> Yes. That's I want it.
> My intention is that if you write down log fully, it can help much
> newbies to understand the patch in future and it would be very clear
> Andrew to merge it.
> 
> What I want is following as.
> ==
> 
> Currently, memory hotplug doesn't updates pcp->stat_threashold.
> Then, It ends up making the wrong stat_threshold and percpu_driftmark.
> 
> It could make confusing zoneinfo or overhead by frequent draining.
> Even when memory is low and kswapd is awake, it can mismatch between
> the number of real free pages and vmstat NR_FREE_PAGES so that it can
> result in the livelock. Please look at aa4548403 for more.
> 
> This patch solves the issue.
> ==

Now, wakeup_kswapd() are using zone_watermark_ok_safe(). (ie avoid to use
per-cpu stat jiffies). Then, I don't think we have livelock chance.
Am I missing something?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
