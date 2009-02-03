Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E99F85F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 01:04:22 -0500 (EST)
Date: Mon, 2 Feb 2009 22:04:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [-mm patch] Show memcg information during OOM
In-Reply-To: <20090203145504.0ffef746.nishimura@mxp.nes.nec.co.jp>
Message-ID: <alpine.DEB.2.00.0902022203400.31820@chino.kir.corp.google.com>
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202134505.GA4848@cmpxchg.org> <20090203124436.bc0120ca.nishimura@mxp.nes.nec.co.jp> <20090203145504.0ffef746.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, Daisuke Nishimura wrote:

> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > index d3b9bac..b8e53ae 100644
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -392,6 +392,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> > > >  			current->comm, gfp_mask, order, current->oomkilladj);
> > > >  		task_lock(current);
> > > >  		cpuset_print_task_mems_allowed(current);
> > > > +		mem_cgroup_print_mem_info(mem);
> > > 
> > > mem is only !NULL when we come from mem_cgroup_out_of_memory().  This
> > > crashes otherwise in mem_cgroup_print_mem_info(), no?
> > > 
> > I think you're right.
> > 
> > IMHO, "mem_cgroup_print_mem_info(current)" would be better here,
> > and call mem_cgroup_from_task at mem_cgroup_print_mem_info.
> > 
> Reading other messages on this thread, mem_cgroup_print_mem_info
> should be called only when oom_kill_process is called from mem_cgroup_out_of_memory,
> so checking "if (!mem)" would be enough.
> 

You're right, but it's understandable why there would be confusion since 
it's very poorly documented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
