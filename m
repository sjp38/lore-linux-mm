Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4BFBB6B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 03:54:39 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBM8saRM021674
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Dec 2010 17:54:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B49745DE5C
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:54:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 55C8945DE54
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:54:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A92FE38001
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:54:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 17403E08001
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:54:36 +0900 (JST)
Date: Wed, 22 Dec 2010 17:48:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20101222174829.226ef641.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1012220043040.24462@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
	<20101221235924.b5c1aecc.akpm@linux-foundation.org>
	<20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1012220043040.24462@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010 00:48:53 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 22 Dec 2010, KAMEZAWA Hiroyuki wrote:
> 
> > seems to be hard to use. No one can estimate "milisecond" for avoidling
> > OOM-kill. I think this is very bad. Nack to this feature itself.
> > 
> 
> There's no estimation that is really needed, we simply need to be able to 
> stall long enough that we'll eventually kill "something" if userspace 
> fails to act.
> 

Why we have to think of usermode failure by mis configuration or user mode bug ?
It's a work of Middleware in usual.
Please make libcgroup or libvirt more useful.

> > If you want something smart _in kernel_, please implement followings.
> > 
> >  - When hit oom, enlarge limit to some extent.
> >  - All processes in cgroup should be stopped.
> >  - A helper application will be called by usermode_helper().
> >  - When a helper application exit(), automatically release all processes
> >    to run again.
> > 
> 
> Hmm, that's a _lot_ of policy to be implemented in the kernel itself and 
> comes at the cost of either being faulty (if the limit cannot be 
> increased) or harmful (when increasing the limit is detrimental to other 
> memcg).
> 

Or runnking a helper function in "root" cgroup which has no limit at all.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
