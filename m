Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0296C5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 02:56:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3H6veEA015027
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Apr 2009 15:57:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1658F45DD80
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 15:57:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A915245DD72
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 15:57:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A93FE1800F
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 15:57:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EB65E08007
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 15:57:38 +0900 (JST)
Date: Fri, 17 Apr 2009 15:56:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v2)
Message-Id: <20090417155608.eeed1f02.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090417064726.GB3896@balbir.in.ibm.com>
References: <20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416171535.cfc4ca84.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416120316.GG7082@balbir.in.ibm.com>
	<20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417014042.GB18558@balbir.in.ibm.com>
	<20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417034539.GD18558@balbir.in.ibm.com>
	<20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417045623.GA3896@balbir.in.ibm.com>
	<20090417141726.a69ebdcc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417064726.GB3896@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Apr 2009 12:17:26 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > *But* we still have following code.
> > ==
> > 820 static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  821                         gfp_t gfp_mask, struct mem_cgroup **memcg,
> >  822    
> >  834         /*
> >  835          * We always charge the cgroup the mm_struct belongs to.
> >  836          * The mm_struct's mem_cgroup changes on task migration if the
> >  837          * thread group leader migrates. It's possible that mm is not
> >  838          * set, if so charge the init_mm (happens for pagecache usage).
> >  839          */
> >  840         mem = *memcg;
> >  841         if (likely(!mem)) {
> >  842                 mem = try_get_mem_cgroup_from_mm(mm);
> >  843                 *memcg = mem;
> >  844         } else {
> >  845                 css_get(&mem->css);
> >  846         }
> >  847         if (unlikely(!mem))
> >  848                 return 0;
> > ==
> > 
> > So, for _now_, we should use this style of checking page_cgroup is used or not.
> > Until we fix/confirm try_charge() does.
> >
> 
> Hmm... I think we need to fix this loop hole, if not mem, we should
> look at charging the root cgroup. I suspect !mem cases should be 0,
> I'll keep that as a TODO. 
> 
yes, I'd like to keep this in my mind, too.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
