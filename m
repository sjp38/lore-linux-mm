Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 30C6E6B0085
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 21:13:58 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAT2DtUH020666
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 29 Nov 2010 11:13:55 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 14A8645DE4D
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:13:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EFB6C45DE61
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:13:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD15F1DB803F
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:13:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A9331DB803B
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:13:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
In-Reply-To: <87pqto3n77.fsf@gmail.com>
References: <20101129090514.829C.A69D9226@jp.fujitsu.com> <87pqto3n77.fsf@gmail.com>
Message-Id: <20101129110848.82A8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 29 Nov 2010 11:13:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> > I don't like this change because fadvise(DONT_NEED) is rarely used
> > function and this PG_reclaim trick doesn't improve so much. In the
> > other hand, It increase VM state mess.
> > 
> 
> Can we please stop appealing to this argument? The reason that
> fadvise(DONT_NEED) is currently rarely employed is that the interface as
> implemented now is extremely kludgey to use.
> 
> Are you proposing that this particular implementation is not worth the
> mess (as opposed to putting the pages at the head of the inactive list
> as done earlier) or would you rather that we simply leave DONT_NEED in
> its current state? Even if today's gains aren't as great as we would
> like them to be, we should still make an effort to make fadvise()
> usable, if for no other reason than to encourage use in user-space so
> that applications can benefit when we finally do figure out how to
> properly account for the user's hints.

Hi

I'm not againt DONT_NEED feature. I only said PG_reclaim trick is not
so effective. Every feature has their own pros/cons. I think the cons
is too big. Also, nobody have mesured PG_reclaim performance gain. Did you?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
