Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5A0335F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 20:19:04 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3H0JKho010868
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Apr 2009 09:19:20 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C47B245DE54
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 09:19:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B65445DE4E
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 09:19:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CBEAE1DB803C
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 09:19:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B214E08009
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 09:19:10 +0900 (JST)
Date: Fri, 17 Apr 2009 09:17:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v2)
Message-Id: <20090417091737.27d71ab7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090415120510.GX7082@balbir.in.ibm.com>
	<20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416015955.GB7082@balbir.in.ibm.com>
	<20090416110246.c3fef293.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416171535.cfc4ca84.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416120316.GG7082@balbir.in.ibm.com>
	<20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Apr 2009 09:14:59 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> page_cgroup->mem_cgroup != try_get_mem_cgroup_from_mm(mm);  in many many cases.
> 
> For example, libc and /bin/*** is tend to be loaded into default cgroup at boot but
> used by many cgroups. But mapcount of page caches for /bin/*** is 0 if not running.
> 
> Then, File_Mapped can be greater than Cached easily if you use mm->owner.
> 
> I can't estimate RSS in *my* cgroup if File_Mapped includes pages which is under 
> other cgroups. It's meaningless.
> Especially, when Cached==0 but File_Mapped > 0, I think "oh, the kernel leaks somehing..hmm..."
> 
> By useing page_cgroup->mem_cgroup, we can avoid above mess.
> 
And, if pc->mem_cgroup is used, we can ignore "task move".

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
