Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA865F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 01:01:14 -0500 (EST)
Date: Tue, 3 Feb 2009 14:55:04 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-Id: <20090203145504.0ffef746.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090203124436.bc0120ca.nishimura@mxp.nes.nec.co.jp>
References: <20090202125240.GA918@balbir.in.ibm.com>
	<20090202134505.GA4848@cmpxchg.org>
	<20090203124436.bc0120ca.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index d3b9bac..b8e53ae 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -392,6 +392,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> > >  			current->comm, gfp_mask, order, current->oomkilladj);
> > >  		task_lock(current);
> > >  		cpuset_print_task_mems_allowed(current);
> > > +		mem_cgroup_print_mem_info(mem);
> > 
> > mem is only !NULL when we come from mem_cgroup_out_of_memory().  This
> > crashes otherwise in mem_cgroup_print_mem_info(), no?
> > 
> I think you're right.
> 
> IMHO, "mem_cgroup_print_mem_info(current)" would be better here,
> and call mem_cgroup_from_task at mem_cgroup_print_mem_info.
> 
Reading other messages on this thread, mem_cgroup_print_mem_info
should be called only when oom_kill_process is called from mem_cgroup_out_of_memory,
so checking "if (!mem)" would be enough.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
