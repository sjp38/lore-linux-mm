Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mASAoPbK000994
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Nov 2008 19:50:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BF5945DE50
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 19:50:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 603D045DE4F
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 19:50:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 49E8EE08005
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 19:50:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 03A71E08002
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 19:50:25 +0900 (JST)
Date: Fri, 28 Nov 2008 19:49:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH -mmotm 0/2] misc patches for memory cgroup
 hierarchy
Message-Id: <20081128194938.508a3b22.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
References: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Nov 2008 18:02:52 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> I'm writing some patches for memory cgroup hierarchy.
> 
> I think KAMEZAWA-san's cgroup-id patches are the most important pathes now,
> but I post these patches as RFC before going further.
> 
Don't wait me ;) I'll rebase mine.


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
 limit of a child or
 limit of sum of children ?

> - Change other calls for mem_cgroup_try_to_free_page() to
>   mem_cgroup_hierarchical_reclaim() if possible.
> 
 maybe makes sense.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
