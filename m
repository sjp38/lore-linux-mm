Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5846B6B0232
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 20:49:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U0nYaU024640
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Mar 2010 09:49:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CEDE45DE4F
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 09:49:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EE55845DE54
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 09:49:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B69FF1DB803B
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 09:49:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 62B9EE38001
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 09:49:30 +0900 (JST)
Date: Tue, 30 Mar 2010 09:45:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg documentaion update
Message-Id: <20100330094546.b7abca6d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49b004811003291747s23c146ffx4a1aecc404b88145@mail.gmail.com>
References: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
	<49b004811003291747s23c146ffx4a1aecc404b88145@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2010 17:47:24 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Sun, Mar 28, 2010 at 11:42 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > At reading Documentation/cgroup/memory.txt, I felt
> >
> > A - old
> > A - hard to find it's supported what I want to do
> >
> > Hmm..maybe some rewrite will be necessary.
> >
> > ==
> > Documentation update. We have too much files now....
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A Documentation/cgroups/memory.txt | A  48 ++++++++++++++++++++++++++++++---------
> > A 1 file changed, 38 insertions(+), 10 deletions(-)
> >
> > Index: mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> > ===================================================================
> > --- mmotm-2.6.34-Mar24.orig/Documentation/cgroups/memory.txt
> > +++ mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> > @@ -4,16 +4,6 @@ NOTE: The Memory Resource Controller has
> > A to as the memory controller in this document. Do not confuse memory controller
> > A used here with the memory controller that is used in hardware.
> >
> > -Salient features
> > -
> > -a. Enable control of Anonymous, Page Cache (mapped and unmapped) and
> > - A  Swap Cache memory pages.
> > -b. The infrastructure allows easy addition of other types of memory to control
> > -c. Provides *zero overhead* for non memory controller users
> > -d. Provides a double LRU: global memory pressure causes reclaim from the
> > - A  global LRU; a cgroup on hitting a limit, reclaims from the per
> > - A  cgroup LRU
> > -
> > A Benefits and Purpose of the memory controller
> >
> > A The memory controller isolates the memory behaviour of a group of tasks
> > @@ -33,6 +23,44 @@ d. A CD/DVD burner could control the amo
> > A e. There are several other use cases, find one or use the controller just
> > A  A for fun (to learn and hack on the VM subsystem).
> >
> > +Current Status: linux-2.6.34-mmotom(2010/March)
> > +
> > +Features:
> > + - accounting anonymous pages, file caches, swap caches usage and limit them.
> > + - private LRU and reclaim routine. (system's global LRU and private LRU
> > + A  work independently from each other)
> > + - optionaly, memory+swap usage
> > + - hierarchical accounting
> > + - softlimit
> > + - moving(recharging) account at moving a task
> > + - usage threshold notifier
> > + - oom-killer disable and oom-notifier
> > + - Root cgroup has no limit controls.
> > +
> > + Kernel memory and Hugepages are not under control yet. We just manage
> > + pages on LRU. To add more controls, we have to take care of performance.
> > +
> > +Brief summary of control files.
> > +
> > + tasks A  A  A  A  A  A  A  A  A  A  A  A  # attach a task(thread)
> > + cgroup.procs A  A  A  A  A  A  A  A  A # attach a process(all threads under it)
> > + cgroup.event_control A  A  A  A  A # an interface for event_fd()
> > + memory.usage_in_bytes A  A  A  A  # show current memory(RSS+Cache) usage.
> > + memory.memsw.usage_in_bytes A  # show current memory+Swap usage.
> > + memory.limit_in_bytes A  A  A  A  # set/show limit of memory usage
> > + memory.memsw.limit_in_bytes A  # set/show limit of memory+Swap usage.
> > + memory.failcnt A  A  A  A  A  A  A  A  A  A  A  A # show the number of memory usage hit limits.
> > + memory.memsw.failcnt A  A  A  A  A # show the number of memory+Swap hit limits.
> > + memory.max_usage_in_bytes A  A  # show max memory usage recorded.
> > + memory.memsw.usage_in_bytes A  # show max memory+Swap usage recorded.
> > + memory.stat A  A  A  A  A  A  A  A  A  # show various statistics.
> > + memory.use_hierarchy A  A  A  A  A # set/show hierarchical account enabled.
> > + memory.force_empty A  A  A  A  A  A # trigger forced move charge to parent.
> > + memory.swappiness A  A  A  A  A  A  # set/show swappiness parameter of vmscan
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  (See sysctl's vm.swappiness)
> > + memory.move_charge_at_immigrate# set/show controls of moving charges
> > + memory.oom_control A  A  A  A  A  A # set/show oom controls.
> > +
> > A 1. History
> >
> > A The memory controller has a long history. A request for comments for the memory
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org. A For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> Two comments:
> 1. Should we also include a description of the
> memory.soft_limit_in_bytes control file in the "Brief summary"
> section?
> 
Oh, it's just a mistake. I'll fix.

> 2. the subject of this thread misspelled "documentation
> (s/documentaion/documentation/).  Not a problem, but you might want to
> fix it for eventually patch submission.
> 
I'll use spell checker in the next post.

Thanks,
-Kame


> --
> Greg
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
