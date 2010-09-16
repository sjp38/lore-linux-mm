Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 777506B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 03:33:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G7XDUQ000350
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Sep 2010 16:33:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B956945DE56
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 16:33:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 89D8945DE58
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 16:33:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AD99E38001
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 16:33:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D34C11DB804C
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 16:33:11 +0900 (JST)
Date: Thu, 16 Sep 2010 16:28:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][-mm] memcg : memory cgroup cpu hotplug support update.
Message-Id: <20100916162807.d2ae50be.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100916161727.04a1f905.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100916062159.GF22371@balbir.in.ibm.com>
	<20100916152204.6c457936.kamezawa.hiroyu@jp.fujitsu.com>
	<20100916161727.04a1f905.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010 16:17:27 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

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

Hmm...css_put() at break from loop is a problem...

Do you have anything good idea to handle "exit-from-loop" operation
with dropping reference count ? I don't like "the caller must take care of"
approach.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
