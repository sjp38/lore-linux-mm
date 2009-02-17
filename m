Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 53D6C6B005D
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 23:42:30 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n1H4gObE005355
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 10:12:24 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1H4dkHW4395190
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 10:09:46 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n1H4gNMS007267
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 10:12:24 +0530
Date: Tue, 17 Feb 2009 10:12:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches (v2)
Message-ID: <20090217044222.GE20958@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090216110844.29795.17804.sendpatchset@localhost.localdomain> <20090217090523.975bbec2.kamezawa.hiroyu@jp.fujitsu.com> <20090217030526.GA20958@balbir.in.ibm.com> <20090217130352.4ba7f91c.kamezawa.hiroyu@jp.fujitsu.com> <20090217132039.3504cd3d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090217132039.3504cd3d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-17 13:20:39]:

> On Tue, 17 Feb 2009 13:03:52 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > > 2. I don't like to change usual direct-memory-reclaim path. It will be obstacles
> > > >    for VM-maintaners to improve memory reclaim. memcg's LRU is designed for
> > > >    shrinking memory usage and not for avoiding memory shortage. IOW, it's slow routine
> > > >    for reclaiming memory for memory shortage.
> > > 
> > > I don't think I agree here. Direct reclaim is the first indication of
> > > shortage and if order 0 pages are short, memcg's above their soft
> > > limit can be targetted first.
> > > 
> > My "slow" means "the overhead seems to be big". The latency will increase.
> > 
> > About 0-order
> > In patch 4/4
> > +	did_some_progress = mem_cgroup_soft_limit_reclaim(gfp_mask);
> > +	/*
> > should be
> >         if (!order)
> >             did_some_progress = mem....
> above is wrong.
> 
> if (!order && (gfp_mask & GFP_MOVABLE)) ....Hmm, but this is not correct.
> I have no good idea to avoid unnecessary works.
> 
> BTW,  why don't you call soft_limit_reclaim from kswapd's path ?
>

I think it has to be both kswapd and pdflush path, I can consider that
option as well. That needs more thought on the design.
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
