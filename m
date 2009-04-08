Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C72475F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 01:27:29 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp08.au.ibm.com (8.13.1/8.13.1) with ESMTP id n38GR2U2005825
	for <linux-mm@kvack.org>; Thu, 9 Apr 2009 02:27:02 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n385RlwU442688
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 15:27:49 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n385RkfV025372
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 15:27:47 +1000
Date: Wed, 8 Apr 2009 10:57:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg remove warning at DEBUG_VM=off
Message-ID: <20090408052715.GX7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090408142042.3fb62eea.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090408142042.3fb62eea.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 14:20:42]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> This is against 2.6.30-rc1. (maybe no problem against mmotm.)
> 
> ==
> Fix warning as
> 
>   CC      mm/memcontrol.o
> mm/memcontrol.c:318: warning: ?$B!Fmem_cgroup_is_obsolete?$B!G defined but not used
> 
> This is called only from VM_BUG_ON().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> Index: linux-2.6.30-rc1/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.30-rc1.orig/mm/memcontrol.c
> +++ linux-2.6.30-rc1/mm/memcontrol.c
> @@ -314,13 +314,14 @@ static struct mem_cgroup *try_get_mem_cg
>  	return mem;
>  }
> 
> +#ifdef CONFIG_DEBUG_VM
>  static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
>  {
>  	if (!mem)
>  		return true;
>  	return css_is_removed(&mem->css);
>  }
> -
> +#endif

Can we change the code to use

        VM_BUG_ON(!mem || css_is_removed(&mem->css));

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
