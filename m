Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA45B6B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 02:35:41 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8H6JhHH015547
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 02:19:43 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8H6Zd5a135562
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 02:35:39 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8H6Zd3T000536
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 03:35:39 -0300
Date: Fri, 17 Sep 2010 12:05:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH][-mm] memcg : memory cgroup cpu hotplug support update.
Message-ID: <20100917063537.GA4534@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100916062159.GF22371@balbir.in.ibm.com>
 <20100916152204.6c457936.kamezawa.hiroyu@jp.fujitsu.com>
 <20100916161727.04a1f905.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100916161727.04a1f905.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-09-16 16:17:27]:

> On Thu, 16 Sep 2010 15:22:04 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > This naming is from mem_cgroup_walk_tree(). Now we have
> > 
> >   mem_cgroup_walk_tree();
> >   mem_cgroup_walk_all();
> > 
> > Rename both ? But it should be in separated patch.
> > 
> 
> Considering a bit ...but..
> 
> #define for_each_mem_cgroup(mem) \
> 	for (mem = mem_cgroup_get_first(); \
> 	     mem; \
> 	     mem = mem_cgroup_get_next(mem);) \
> 
> seems to need some helper functions. I'll consider about this clean up
> but it requires some amount of patch because css_get()/css_put()/rcu...etc..
> are problematic.
>

Why does this need to be a macro (I know we use this for lists and
other places), assuming for now we don't use the iterator pattern, we
can rename mem_cgroup_walk_all() to for_each_mem_cgroup(). 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
