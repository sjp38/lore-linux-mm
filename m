Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 97D746B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 05:52:16 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BAqEju003643
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 19:52:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BA38745DE57
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 19:52:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B8D745DE54
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 19:52:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 91A90E38004
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 19:52:13 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 39177E18002
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 19:52:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: initialize sc->nr_reclaimed properly take2
In-Reply-To: <20090210140637.902e4dcc.akpm@linux-foundation.org>
References: <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210140637.902e4dcc.akpm@linux-foundation.org>
Message-Id: <20090211195116.C3BA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 19:52:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, hannes@cmpxchg.org, riel@redhat.com, wli@movementarian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > @@ -2245,6 +2247,7 @@ static int __zone_reclaim(struct zone *z
> >  	struct reclaim_state reclaim_state;
> >  	int priority;
> >  	struct scan_control sc = {
> > +		.nr_reclaimed = 0,
> >  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> >  		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> >  		.swap_cluster_max = max_t(unsigned long, nr_pages,
> 
> Confused.  The compiler already initialises any unmentioned fields to zero,
> so this patch has no effect.

maybe, I was slept too ;-/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
