Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88D676B022F
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 20:47:50 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o2U0ljFL019035
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 17:47:46 -0700
Received: from gyg13 (gyg13.prod.google.com [10.243.50.141])
	by wpaz24.hot.corp.google.com with ESMTP id o2U0li06005303
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 17:47:44 -0700
Received: by gyg13 with SMTP id 13so1940595gyg.33
        for <linux-mm@kvack.org>; Mon, 29 Mar 2010 17:47:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 29 Mar 2010 17:47:24 -0700
Message-ID: <49b004811003291747s23c146ffx4a1aecc404b88145@mail.gmail.com>
Subject: Re: [RFC][PATCH] memcg documentaion update
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Mar 28, 2010 at 11:42 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> At reading Documentation/cgroup/memory.txt, I felt
>
> =A0- old
> =A0- hard to find it's supported what I want to do
>
> Hmm..maybe some rewrite will be necessary.
>
> =3D=3D
> Documentation update. We have too much files now....
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 48 ++++++++++++++++++++++++++++=
++---------
> =A01 file changed, 38 insertions(+), 10 deletions(-)
>
> Index: mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.34-Mar24.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> @@ -4,16 +4,6 @@ NOTE: The Memory Resource Controller has
> =A0to as the memory controller in this document. Do not confuse memory co=
ntroller
> =A0used here with the memory controller that is used in hardware.
>
> -Salient features
> -
> -a. Enable control of Anonymous, Page Cache (mapped and unmapped) and
> - =A0 Swap Cache memory pages.
> -b. The infrastructure allows easy addition of other types of memory to c=
ontrol
> -c. Provides *zero overhead* for non memory controller users
> -d. Provides a double LRU: global memory pressure causes reclaim from the
> - =A0 global LRU; a cgroup on hitting a limit, reclaims from the per
> - =A0 cgroup LRU
> -
> =A0Benefits and Purpose of the memory controller
>
> =A0The memory controller isolates the memory behaviour of a group of task=
s
> @@ -33,6 +23,44 @@ d. A CD/DVD burner could control the amo
> =A0e. There are several other use cases, find one or use the controller j=
ust
> =A0 =A0for fun (to learn and hack on the VM subsystem).
>
> +Current Status: linux-2.6.34-mmotom(2010/March)
> +
> +Features:
> + - accounting anonymous pages, file caches, swap caches usage and limit =
them.
> + - private LRU and reclaim routine. (system's global LRU and private LRU
> + =A0 work independently from each other)
> + - optionaly, memory+swap usage
> + - hierarchical accounting
> + - softlimit
> + - moving(recharging) account at moving a task
> + - usage threshold notifier
> + - oom-killer disable and oom-notifier
> + - Root cgroup has no limit controls.
> +
> + Kernel memory and Hugepages are not under control yet. We just manage
> + pages on LRU. To add more controls, we have to take care of performance=
.
> +
> +Brief summary of control files.
> +
> + tasks =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 # attach a task(t=
hread)
> + cgroup.procs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# attach a process(all =
threads under it)
> + cgroup.event_control =A0 =A0 =A0 =A0 =A0# an interface for event_fd()
> + memory.usage_in_bytes =A0 =A0 =A0 =A0 # show current memory(RSS+Cache) =
usage.
> + memory.memsw.usage_in_bytes =A0 # show current memory+Swap usage.
> + memory.limit_in_bytes =A0 =A0 =A0 =A0 # set/show limit of memory usage
> + memory.memsw.limit_in_bytes =A0 # set/show limit of memory+Swap usage.
> + memory.failcnt =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# show th=
e number of memory usage hit limits.
> + memory.memsw.failcnt =A0 =A0 =A0 =A0 =A0# show the number of memory+Swa=
p hit limits.
> + memory.max_usage_in_bytes =A0 =A0 # show max memory usage recorded.
> + memory.memsw.usage_in_bytes =A0 # show max memory+Swap usage recorded.
> + memory.stat =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 # show various statisti=
cs.
> + memory.use_hierarchy =A0 =A0 =A0 =A0 =A0# set/show hierarchical account=
 enabled.
> + memory.force_empty =A0 =A0 =A0 =A0 =A0 =A0# trigger forced move charge =
to parent.
> + memory.swappiness =A0 =A0 =A0 =A0 =A0 =A0 # set/show swappiness paramet=
er of vmscan
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (See sy=
sctl's vm.swappiness)
> + memory.move_charge_at_immigrate# set/show controls of moving charges
> + memory.oom_control =A0 =A0 =A0 =A0 =A0 =A0# set/show oom controls.
> +
> =A01. History
>
> =A0The memory controller has a long history. A request for comments for t=
he memory
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

Two comments:
1. Should we also include a description of the
memory.soft_limit_in_bytes control file in the "Brief summary"
section?

2. the subject of this thread misspelled "documentation
(s/documentaion/documentation/).  Not a problem, but you might want to
fix it for eventually patch submission.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
