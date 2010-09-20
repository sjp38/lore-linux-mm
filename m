Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1B89B6B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 03:54:43 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8K7qYYl010111
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 01:52:34 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8K7sboE109914
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 01:54:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8K7sbCq009134
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 01:54:37 -0600
Date: Mon, 20 Sep 2010 13:24:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH][-mm] memcg : memory cgroup cpu hotplug support update.
Message-ID: <20100920075433.GB6676@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100916062159.GF22371@balbir.in.ibm.com>
 <20100916152204.6c457936.kamezawa.hiroyu@jp.fujitsu.com>
 <20100916161727.04a1f905.kamezawa.hiroyu@jp.fujitsu.com>
 <20100917063537.GA4534@balbir.in.ibm.com>
 <AANLkTikWqPf_SfYn7fzL7ROGqCY=ZZR5mUzr7sah+TOd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikWqPf_SfYn7fzL7ROGqCY=ZZR5mUzr7sah+TOd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com> [2010-09-17 20:49:09]:

> 2010/9/17 Balbir Singh <balbir@linux.vnet.ibm.com>:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-09-16 16:17:27]:
> >
> >> On Thu, 16 Sep 2010 15:22:04 +0900
> >> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >>
> >> > This naming is from mem_cgroup_walk_tree(). Now we have
> >> >
> >> >   mem_cgroup_walk_tree();
> >> >   mem_cgroup_walk_all();
> >> >
> >> > Rename both ? But it should be in separated patch.
> >> >
> >>
> >> Considering a bit ...but..
> >>
> >> #define for_each_mem_cgroup(mem) \
> >>       for (mem = mem_cgroup_get_first(); \
> >>            mem; \
> >>            mem = mem_cgroup_get_next(mem);) \
> >>
> >> seems to need some helper functions. I'll consider about this clean up
> >> but it requires some amount of patch because css_get()/css_put()/rcu...etc..
> >> are problematic.
> >>
> >
> > Why does this need to be a macro (I know we use this for lists and
> > other places), assuming for now we don't use the iterator pattern, we
> > can rename mem_cgroup_walk_all() to for_each_mem_cgroup().
> >
> 
> When I see for_each in the kernel source, I expect iterator and macro.
> When I see "walk" in the kernel source, I expect callback and visit function.
>

I understand that is the convention we used thus far. When I see
for_each for walk, I presume iterators, doesn't matter if we have a
call back or not. I'll leave the decision to you. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
