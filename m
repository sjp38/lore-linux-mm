Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E5B0E6B01EF
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 20:27:25 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3M0RMbs018478
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Apr 2010 09:27:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F8BF45DE6E
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:27:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C8F445DE60
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:27:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 141E81DB803A
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:27:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AB2FA1DB8037
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:27:18 +0900 (JST)
Date: Thu, 22 Apr 2010 09:23:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-Id: <20100422092324.3900c5d4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1004211502430.25558@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
	<20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100407205418.FB90.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
	<20100421121758.af52f6e0.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1004211502430.25558@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Apr 2010 15:04:27 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 21 Apr 2010, Andrew Morton wrote:
> 
> > fyi, I still consider these patches to be in the "stuck" state.  So we
> > need to get them unstuck.
> > 
> > 
> > Hiroyuki (and anyone else): could you please summarise in the briefest
> > way possible what your objections are to Daivd's oom-killer changes?
> > 
> > I'll start: we don't change the kernel ABI.  Ever.  And when we _do_
> > change it we don't change it without warning.
> > 
> 
> I'm not going to allow a simple cleanup to jeopardize the entire patchset, 
> so I can write a patch that readds /proc/sys/vm/oom_kill_allocating_task 
> that simply mirrors the setting of /proc/sys/vm/oom_kill_quick and then 
> warn about its deprecation. 

Yeah, I welcome it.

> I don't believe we need to do the same thing 
> for the removal of /proc/sys/vm/oom_dump_tasks since that functionality is 
> now enabled by default.
> 

But *warning* is always apprecieated and will not make the whole patches
too dirty. So, please write one.

BTW, I don't think there is an admin who turns off oom_dump_task..
So, just keeping interface and putting this one to feature-removal-list 
is okay for me if you want to cleanup sysctl possibly.

Talking about myself, I also want to remove/cleanup some interface under memcg
which is rarely used. But I don't do because we have users. And I'll not to
clean up as far as we can maintain it. Then, we have to be careful to add
interfaces.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
