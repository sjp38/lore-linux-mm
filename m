Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE026B003D
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 22:37:57 -0500 (EST)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp07.au.ibm.com (8.13.1/8.13.1) with ESMTP id n143bqlJ016759
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 14:37:52 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n143cAH8950510
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 14:38:10 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n143bqaT016038
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 14:37:52 +1100
Date: Wed, 4 Feb 2009 09:07:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
Message-ID: <20090204033750.GB4456@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090203172135.GF918@balbir.in.ibm.com> <4988E727.8030807@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4988E727.8030807@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Li Zefan <lizf@cn.fujitsu.com> [2009-02-04 08:53:59]:

> > @@ -104,6 +104,8 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
> >  						      struct zone *zone);
> >  struct zone_reclaim_stat*
> >  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> > +extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> > +					struct task_struct *p);
> >  
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  extern int do_swap_account;
> > @@ -270,6 +272,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
> >  	return NULL;
> >  }
> >  
> > +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> > +{
> 
> should be static inline, otherwise it won't compile if CONFIG_CGROUP_MEM_CONT=n
> 

Oh! yes.

> > +}
> > +
> >  #endif /* CONFIG_CGROUP_MEM_CONT */
> >  
> 
> > +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> > +{
> > +	struct cgroup *task_cgrp;
> > +	struct cgroup *mem_cgrp;
> > +	/*
> > +	 * Need a buffer on stack, can't rely on allocations. The code relies
> 
> I think it's in .bss section, but not on stack, and it's better to explain why
> the static buffer is safe in the comment.
>

Yes, it is no longer on stack, in the original patch it was. I'll send
an updated patch 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
