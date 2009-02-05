Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE6D6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 16:56:23 -0500 (EST)
Date: Thu, 5 Feb 2009 13:55:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
Message-Id: <20090205135554.61488ed6.akpm@linux-foundation.org>
In-Reply-To: <20090203144647.09bf9c97.akpm@linux-foundation.org>
References: <20090203172135.GF918@balbir.in.ibm.com>
	<20090203144647.09bf9c97.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009 14:46:47 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > +/**
> > + * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in
> > + * read mode.
> > + * @memcg: The memory cgroup that went over limit
> > + * @p: Task that is going to be killed
> > + *
> > + * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
> > + * enabled
> > + */
> > +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> > +{
> > +	struct cgroup *task_cgrp;
> > +	struct cgroup *mem_cgrp;
> > +	/*
> > +	 * Need a buffer on stack, can't rely on allocations. The code relies
> > +	 * on the assumption that OOM is serialized for memory controller.
> > +	 * If this assumption is broken, revisit this code.
> > +	 */
> > +	static char task_memcg_name[PATH_MAX];
> > +	static char memcg_name[PATH_MAX];
> 
> I don't think we need both of these.  With a bit of shuffling we could
> reuse the single buffer?

ping?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
