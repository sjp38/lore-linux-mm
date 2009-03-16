Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 634B96B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:10:38 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2G8faN2000738
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:11:36 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2G9AeYQ4206616
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:40:40 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2G9AVCL017229
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:10:31 +1100
Date: Mon, 16 Mar 2009 14:40:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v6)
Message-ID: <20090316091024.GX16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain> <20090314173111.16591.68465.sendpatchset@localhost.localdomain> <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com> <20090316083512.GV16897@balbir.in.ibm.com> <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com> <20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16 18:03:08]:

> On Mon, 16 Mar 2009 17:49:43 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Mon, 16 Mar 2009 14:05:12 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > For example, shrink_slab() is not called. and this must be called.
> > 
> > For exmaple, we may have to add 
> >  sc->call_shrink_slab
> > flag and set it "true" at soft limit reclaim. 
> > 
> At least, this check will be necessary in v7, I think.
> shrink_slab() should be called.

Why do you think so? So here is the design

1. If a cgroup was using over its soft limit, we believe that this
   cgroup created overall memory contention and caused the page
   reclaimer to get activated. If we can solve the situation by
   reclaiming from this cgroup, why do we need to invoke shrink_slab?

If the concern is that we are not following the traditional reclaim,
soft limit reclaim can be followed by unconditional reclaim, but I
believe this is not necessary. Remember, we wake up kswapd that will
call shrink_slab if needed.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
