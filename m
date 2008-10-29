Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9T5k8LO028388
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 29 Oct 2008 14:46:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 702492AC026
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:46:08 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C12C12C045
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:46:08 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 242111DB803E
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:46:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id C15F11DB803A
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:46:07 +0900 (JST)
Date: Wed, 29 Oct 2008 14:45:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [discuss][memcg] oom-kill extension
Message-Id: <20081029144539.b6c96cb8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830810282235w5ad7ff7cx4f8be4e1f58933a5@mail.gmail.com>
References: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830810282235w5ad7ff7cx4f8be4e1f58933a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


On Tue, 28 Oct 2008 22:35:21 -0700
"Paul Menage" <menage@google.com> wrote:

> On Tue, Oct 28, 2008 at 7:38 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Under memory resource controller(memcg), oom-killer can be invoked when it
> > reaches limit and no memory can be reclaimed.
> >
> > In general, not under memcg, oom-kill(or panic) is an only chance to recover
> > the system because there is no available memory. But when oom occurs under
> > memcg, it just reaches limit and it seems we can do something else.
> >
> > Does anyone have plan to enhance oom-kill ?
> 
> We have an in-house implementation of a per-cgroup OOM handler that
> we've just ported from cpusets to cgroups. We were considering sending
> the patch in as a starting point for discussions - it's a bit of a
> kludge as it is.
> 
Sounds interesting. (but I don't ask details now.)

> It's a standalone subsystem that can work with either the memory
> cgroup or with cpusets (where memory is constrained by numa nodes).
> The features are:
> 
> - an oom.delay file that controls how long a thread will pause in the
> OOM killer waiting for a response from userspace (in milliseconds)
> 
> - an oom.await file that a userspace handler can write a timeout value
> to, and be awoken either when a process in that cgroup enters the OOM
> killer, or the timeout expires.
> 
> If a userspace thread catches and handles the OOM, the OOMing thread
> doesn't trigger a kill, but returns to alloc_pages to try again;
> alternatively userspace can cause the OOM killer to go ahead as
> normal.
> 
the userland can know "bad process" under group ?

> We've found it works pretty successfully as a last-ditch notification
> to a daemon waiting in a system cgroup which can then expand the
> memory limits of the failing cgroup if necessary (potentially killing
> off processes from some other cgroup first if necessary to free up
> more memory).
> 
This is a good news :)

> I'll try to get someone to send in the patch.
> 
O.K. looking forward to see that.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
