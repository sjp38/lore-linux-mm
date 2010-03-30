Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EBCCF6B022D
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 20:19:15 -0400 (EDT)
Date: Tue, 30 Mar 2010 09:13:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] memcg documentaion update
Message-Id: <20100330091303.14a06e85.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2010 15:42:45 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> At reading Documentation/cgroup/memory.txt, I felt
> 
>  - old
>  - hard to find it's supported what I want to do
> 
> Hmm..maybe some rewrite will be necessary.
> 
I agree.

> ==
> Documentation update. We have too much files now....
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |   48 ++++++++++++++++++++++++++++++---------
>  1 file changed, 38 insertions(+), 10 deletions(-)
> 
> Index: mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-2.6.34-Mar24.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> @@ -4,16 +4,6 @@ NOTE: The Memory Resource Controller has
>  to as the memory controller in this document. Do not confuse memory controller
>  used here with the memory controller that is used in hardware.
>  
> -Salient features
> -
> -a. Enable control of Anonymous, Page Cache (mapped and unmapped) and
> -   Swap Cache memory pages.
> -b. The infrastructure allows easy addition of other types of memory to control
> -c. Provides *zero overhead* for non memory controller users
> -d. Provides a double LRU: global memory pressure causes reclaim from the
> -   global LRU; a cgroup on hitting a limit, reclaims from the per
> -   cgroup LRU
> -
>  Benefits and Purpose of the memory controller
>  
>  The memory controller isolates the memory behaviour of a group of tasks
> @@ -33,6 +23,44 @@ d. A CD/DVD burner could control the amo
>  e. There are several other use cases, find one or use the controller just
>     for fun (to learn and hack on the VM subsystem).
>  
> +Current Status: linux-2.6.34-mmotom(2010/March)
> +
> +Features:
> + - accounting anonymous pages, file caches, swap caches usage and limit them.
> + - private LRU and reclaim routine. (system's global LRU and private LRU
> +   work independently from each other)
> + - optionaly, memory+swap usage
> + - hierarchical accounting
> + - softlimit
> + - moving(recharging) account at moving a task
> + - usage threshold notifier
> + - oom-killer disable and oom-notifier
> + - Root cgroup has no limit controls.
> +
> + Kernel memory and Hugepages are not under control yet. We just manage
> + pages on LRU. To add more controls, we have to take care of performance.
> +
> +Brief summary of control files.
> +
> + tasks				# attach a task(thread)
> + cgroup.procs			# attach a process(all threads under it)
> + cgroup.event_control		# an interface for event_fd()
> + memory.usage_in_bytes		# show current memory(RSS+Cache) usage.
> + memory.memsw.usage_in_bytes	# show current memory+Swap usage.
> + memory.limit_in_bytes		# set/show limit of memory usage
> + memory.memsw.limit_in_bytes	# set/show limit of memory+Swap usage.
> + memory.failcnt			# show the number of memory usage hit limits.
> + memory.memsw.failcnt		# show the number of memory+Swap hit limits.
> + memory.max_usage_in_bytes	# show max memory usage recorded.
> + memory.memsw.usage_in_bytes	# show max memory+Swap usage recorded.
> + memory.stat			# show various statistics.
> + memory.use_hierarchy		# set/show hierarchical account enabled.
> + memory.force_empty		# trigger forced move charge to parent.
> + memory.swappiness		# set/show swappiness parameter of vmscan
> + 				  (See sysctl's vm.swappiness)
> + memory.move_charge_at_immigrate# set/show controls of moving charges
> + memory.oom_control		# set/show oom controls.
> +
These changes would be very useful to let users know memcg's features at a glance.

>  1. History
>  
>  The memory controller has a long history. A request for comments for the memory
> 

BTW, I think it might be better to update 5.2(stat file) too.
"mapped_file" and "swap"(sorry, my fault) aren't listed there.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
