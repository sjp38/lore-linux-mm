Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DF5FC6B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 04:01:05 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBM912uV016064
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Dec 2010 18:01:02 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0FB945DD74
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 18:01:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B0CD45DE4E
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 18:01:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E7A51DB8038
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 18:01:02 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 57A391DB803A
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 18:01:02 +0900 (JST)
Date: Wed, 22 Dec 2010 17:55:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20101222175515.9e88917a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101222174829.226ef641.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
	<20101221235924.b5c1aecc.akpm@linux-foundation.org>
	<20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1012220043040.24462@chino.kir.corp.google.com>
	<20101222174829.226ef641.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010 17:48:29 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 22 Dec 2010 00:48:53 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Wed, 22 Dec 2010, KAMEZAWA Hiroyuki wrote:
> > 
> > > seems to be hard to use. No one can estimate "milisecond" for avoidling
> > > OOM-kill. I think this is very bad. Nack to this feature itself.
> > > 
> > 
> > There's no estimation that is really needed, we simply need to be able to 
> > stall long enough that we'll eventually kill "something" if userspace 
> > fails to act.
> > 
> 
> Why we have to think of usermode failure by mis configuration or user mode bug ?
> It's a work of Middleware in usual.

For example. oom_check_deadlockd can work as

  1. disable oom by memory.oom_disable=1
  2. check memory.oom_notify and wait it by poll()
  3. At oom, it wakes up.
  4. wait for 60 secs.
  5. If the cgroup is still in OOM, set oom_disalble=0

This daemon will not use much memory and can run in /roog memory cgroup.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
