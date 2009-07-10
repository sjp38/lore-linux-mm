Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC6E6B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 09:57:59 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6AEJk2h001560
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:19:46 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6AEMwmk101562
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:23:00 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6AEMwk9004239
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:22:58 -0600
Date: Fri, 10 Jul 2009 19:52:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/5] Memory controller soft limit reclaim on
	contention (v8)
Message-ID: <20090710142256.GL20129@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop> <20090709171512.8080.8138.sendpatchset@balbir-laptop> <20090710143026.4de7d4b9.kamezawa.hiroyu@jp.fujitsu.com> <20090710065306.GC20129@balbir.in.ibm.com> <20090710163056.a9d552e2.kamezawa.hiroyu@jp.fujitsu.com> <20090710074906.GE20129@balbir.in.ibm.com> <20090710105620.GI20129@balbir.in.ibm.com> <fda5a0e71781c85d850573fd9166c895.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <fda5a0e71781c85d850573fd9166c895.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-10 23:15:20]:

> Balbir Singh wrote?$B!'
> > * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-07-10 13:19:06]:
> >>
> >> Yes, worth experimenting with, I'll redo with the special code
> >> removed.
> >
> >
> > OK, so I experimented with it, I found the following behaviour
> >
> > 1. We try to reclaim, priority is high, scanned pages are low and
> >    hence memory cgroup zone reclaim returns 0 (no pages could be
> >    reclaimed).
> > 2. Now regular reclaim from balance_pgdat() is called, it is able
> >    to shrink from global LRU and hence some other mem cgroup, thus
> >    breaking soft limit semantics.
> >
> IMO, "breaking soft limit" cannot be an excuse for delaying kswapd too much.
>

Hmmm... I agree in principle, but if soft limits are turned on, we are
overriding where we should be reclaiming from. The delay IMHO is not
very high and I've run tests without setting any soft limits but with
soft limits feature enabled. I don't see anything going bad or any
overhead.

I've just posted v9 without the changes. I'll do some runs with your
suggestion and see what the complete impact is.
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
