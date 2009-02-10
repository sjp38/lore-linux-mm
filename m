Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8DBAC6B0047
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 07:06:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1AC6dwR032337
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 21:06:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7422845DE61
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:06:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DE9A45DE51
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:06:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 172E41DB8041
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:06:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F245B1DB803C
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:06:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] vmscan: initialize sc->nr_reclaimed in do_try_to_free_pages()
In-Reply-To: <28c262360902100403m772576afp3c9212157dc9fcd@mail.gmail.com>
References: <20090210204210.6FEF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <28c262360902100403m772576afp3c9212157dc9fcd@mail.gmail.com>
Message-Id: <20090210210520.7004.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 21:06:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > {
> >        /* Minimum pages needed in order to stay on node */
> >        const unsigned long nr_pages = 1 << order;
> >        struct task_struct *p = current;
> >        struct reclaim_state reclaim_state;
> >        int priority;
> >        struct scan_control sc = {
> >                .may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> >                .may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> >                .swap_cluster_max = max_t(unsigned long, nr_pages,
> >                                        SWAP_CLUSTER_MAX),
> >                .gfp_mask = gfp_mask,
> >                .swappiness = vm_swappiness,
> >                .isolate_pages = isolate_pages_global,
> > +               .nr_reclaimed = 0;
> >        };
> 
> Hmm.. I missed that.  Thanks.
> There is one in shrink_all_memory.

No.
__zone_reclaim isn't a part of shrink_all_memory().

Currently, shrink_all_memory() don't use sc.nr_reclaimed member.
(maybe, it's another wrong thing ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
