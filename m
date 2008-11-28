Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id mASIIcpB001606
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 23:48:38 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mASIIdmT3362890
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 23:48:39 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id mASIIbgl021816
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 05:18:37 +1100
Date: Fri, 28 Nov 2008 23:48:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH -mmotm 0/2] misc patches for memory cgroup
	hierarchy
Message-ID: <20081128181835.GA12948@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2008-11-28 18:02:52]:

> Hi.
> 
> I'm writing some patches for memory cgroup hierarchy.
> 
> I think KAMEZAWA-san's cgroup-id patches are the most important pathes now,
> but I post these patches as RFC before going further.
> 
> Patch descriptions:
> - [1/2] take account of memsw
>     mem_cgroup_hierarchical_reclaim checks only mem->res now.
>     It should also check mem->memsw when do_swap_account.
> - [2/2] avoid oom
>     In previous implementation, mem_cgroup_try_charge checked the return
>     value of mem_cgroup_try_to_free_pages, and just retried if some pages
>     had been reclaimed.
>     But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
>     only checks whether the usage is less than the limit.
>     I see oom easily in some tests which didn't cause oom before.
> 
> Both patches are for memory-cgroup-hierarchical-reclaim-v4 patch series.
> 
> My current plan for memory cgroup hierarchy:
> - If hierarchy is enabled, limit of child should not exceed that of parent.
> - Change other calls for mem_cgroup_try_to_free_page() to
>   mem_cgroup_hierarchical_reclaim() if possible.
>

Thanks, Daisuke,

I am in a conference and taken a quick look. The patches seem sane,
but I've not reviewed them carefully. I'll revert back next week
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
