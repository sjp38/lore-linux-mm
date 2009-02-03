Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD665F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 00:35:58 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n135ZrWH017561
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 11:05:53 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n135XZns4444180
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 11:03:35 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n135ZqfJ012564
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 16:35:53 +1100
Date: Tue, 3 Feb 2009 11:05:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-ID: <20090203053551.GP918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202140849.GB918@balbir.in.ibm.com> <49879DE5.8030505@cn.fujitsu.com> <20090203044143.GM918@balbir.in.ibm.com> <alpine.DEB.2.00.0902022045170.27139@chino.kir.corp.google.com> <4987D512.90001@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4987D512.90001@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Li Zefan <lizf@cn.fujitsu.com> [2009-02-03 13:24:34]:

> David Rientjes wrote:
> > On Tue, 3 Feb 2009, Balbir Singh wrote:
> > 
> >>>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> >>>> index d3b9bac..b8e53ae 100644
> >>>> --- a/mm/oom_kill.c
> >>>> +++ b/mm/oom_kill.c
> >>>> @@ -392,6 +392,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >>>>  			current->comm, gfp_mask, order, current->oomkilladj);
> >>>>  		task_lock(current);
> >>>>  		cpuset_print_task_mems_allowed(current);
> >>>> +		mem_cgroup_print_mem_info(mem);
> >>> I think this can be put outside the task lock. The lock is used to call task_cs() safely in
> >>> cpuset_print_task_mems_allowed().
> >>>
> >> Thanks, I'll work on that in the next version.
> >>  
> > 
> > I was also wondering about this and assumed that it was necessary to 
> > prevent the cgroup from disappearing during the oom.  If task_lock() isn't 
> > held, is the memcg->css.cgroup->dentry->d_name.name dereference always 
> > safe without rcu?
> > 
> 
> The cgroup won't disappear, since mem_cgroup_out_of_memory() is called with memcg's css refcnt
> increased. :)
>

And this as well, yes!
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
