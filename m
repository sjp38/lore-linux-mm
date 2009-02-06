Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5DC6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 21:26:12 -0500 (EST)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n162Q4WM025027
	for <linux-mm@kvack.org>; Fri, 6 Feb 2009 13:26:04 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n162QK8Y1138716
	for <linux-mm@kvack.org>; Fri, 6 Feb 2009 13:26:23 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n162Q2wi005922
	for <linux-mm@kvack.org>; Fri, 6 Feb 2009 13:26:03 +1100
Date: Fri, 6 Feb 2009 07:56:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
Message-ID: <20090206022600.GC13655@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090203172135.GF918@balbir.in.ibm.com> <20090203144647.09bf9c97.akpm@linux-foundation.org> <20090205135554.61488ed6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090205135554.61488ed6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-02-05 13:55:54]:

> On Tue, 3 Feb 2009 14:46:47 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > +/**
> > > + * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in
> > > + * read mode.
> > > + * @memcg: The memory cgroup that went over limit
> > > + * @p: Task that is going to be killed
> > > + *
> > > + * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
> > > + * enabled
> > > + */
> > > +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> > > +{
> > > +	struct cgroup *task_cgrp;
> > > +	struct cgroup *mem_cgrp;
> > > +	/*
> > > +	 * Need a buffer on stack, can't rely on allocations. The code relies
> > > +	 * on the assumption that OOM is serialized for memory controller.
> > > +	 * If this assumption is broken, revisit this code.
> > > +	 */
> > > +	static char task_memcg_name[PATH_MAX];
> > > +	static char memcg_name[PATH_MAX];
> > 
> > I don't think we need both of these.  With a bit of shuffling we could
> > reuse the single buffer?
> 
> ping?
>

We can use a single buffer, I'll post a patch to fix it.
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
