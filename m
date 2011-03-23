Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C7EE38D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 03:55:18 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7C4FD3EE0C1
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:55:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 634E345DE5A
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:55:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B03745DE55
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:55:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 34D2CE38004
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:55:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F03EEE38001
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:55:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <20110323164122.ea25bdf0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110322200523.B061.A69D9226@jp.fujitsu.com> <20110323164122.ea25bdf0.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20110323165552.1AD6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 23 Mar 2011 16:55:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

> > Reported-by: Andrey Vagin <avagin@openvz.org>
> > Cc: Nick Piggin <npiggin@kernel.dk>
> > Cc: Minchan Kim <minchan.kim@gmail.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> IIUC, I saw the pehnomenon which you pointed out, as
>  - all zone->all_unreclaimable = yes
>  - zone_reclaimable() returns true
>  - no pgscan proceeds.
> 
> on a swapless system. So, I'd like to vote for this patch.
> 
> But hmm...what happens all of pages are isolated or locked and now under freeing ?
> I think we should have alternative safe-guard logic for avoiding to call
> oom-killer. Hmm.

Yes, this patch has small risk. but 1) this logic didn't work about two
years (see changelog) 2) memcg haven't use this logic and I haven't get
any bug report from memcg developers. therefore I decided to take most
simple way.

Of cource, I'll make another protection if I'll get any regression report.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
