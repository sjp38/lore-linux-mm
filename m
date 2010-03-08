Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 78C066B0082
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 19:00:49 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2900lJF015672
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Mar 2010 09:00:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2301E45DE51
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 09:00:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D2A361EF081
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 09:00:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B87431DB803E
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 09:00:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5642D1DB8040
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 09:00:46 +0900 (JST)
Date: Tue, 9 Mar 2010 08:57:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/2]  memcg: oom notifier and handling oom by user
Message-Id: <20100309085711.f9158491.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100308172609.GS3073@balbir.in.ibm.com>
References: <20100308162414.faaa9c5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308172609.GS3073@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Mar 2010 22:56:09 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-08 16:24:14]:
> 
> > This 2 patches is for memcg's oom handling.
> > 
> > At first, memcg's oom doesn't mean "no more resource" but means "we hit limit."
> > Then, daemons/user shells out of a memcg can work even if it's under oom.
> > So, if we have notifier and some more features, we can do something moderate
> > rather than killing at oom. 
> > 
> > This patch includes
> > [1/2] oom notifier for memcg (using evetfd framework of cgroups.)
> > [2/2] oom killer disalibing and hooks for waitq and wake-up.
> > 
> > When memcg's oom-killer is disabled, all tasks which request accountable memory
> > will sleep in waitq. It will be waken up by user's action as
> >  - enlarge limit. (memory or memsw)
> >  - kill some tasks
> >  - move some tasks (account migration is enabled.)
> > 
> 
> Hmm... I've not seen the waitq and wake-up patches, but does that mean
> user space will control resumtion of tasks?
> 
Yes. And what's useful in this behavior rathar than oom-kill(SIGKILL) by
the kernel is that users can take coredump (by gcore at el.) and snapshot of
all tasks's resource usage (by ps at el.) even if he has to kill a task.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
