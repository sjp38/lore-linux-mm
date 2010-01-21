Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B60D36B0071
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 18:57:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0LNvdb2019942
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Jan 2010 08:57:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CE0A45DE4E
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:57:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A29745DE51
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:57:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 259AC1DB8038
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:57:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A444D1DB803C
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 08:57:38 +0900 (JST)
Date: Fri, 22 Jan 2010 08:54:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100122085420.38d8adea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B5872EC.5040603@linux.vnet.ibm.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<4B5872EC.5040603@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010 20:59:48 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> On Thursday 21 January 2010 11:29 AM, KAMEZAWA Hiroyuki wrote:
> > A patch for avoiding oom-serial-killer at lowmem shortage.
> > Patch is onto mmotm-2010/01/15 (depends on mm-count-lowmem-rss.patch)
> > Tested on x86-64/SMP + debug module(to allocated lowmem), works well.
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > One cause of OOM-Killer is memory shortage in lower zones.
> > (If memory is enough, lowmem_reserve_ratio works well. but..)
> > 
> > In lowmem-shortage oom-kill, oom-killer choses a vicitim process
> > on their vm size. But this kills a process which has lowmem memory
> > only if it's lucky. At last, there will be an oom-serial-killer.
> > 
> > Now, we have per-mm lowmem usage counter. We can make use of it
> > to select a good? victim.
> 
> Have you seen any use cases that need this change? Or is it mostly via
> code review and to utilize the availability of lowmem rss? Do we often
> run into lowmem shortage triggering OOM?
> 
  - I saw lowmem OOM killer very frequently on x86-32 box in my cusotmers.
  - I saw lowmem OOM killer somemtimes on ia64 box in my customers.

I know this helps oom handling in x86-32+Highmem environments.

For my _new_ customers, almost all devices are connected to 64bit PCI bus.
So, this is not for my customers ;) But OOM-Killer should handle this case.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
