Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94CB98D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 05:36:05 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C40B93EE0BD
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 19:36:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A95D645DE5F
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 19:36:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C68F45DE56
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 19:36:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 67073E3800B
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 19:36:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EED76E38009
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 19:36:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
References: <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
Message-Id: <20110309192955.040C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  9 Mar 2011 19:36:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

> On Tue, 8 Mar 2011, Oleg Nesterov wrote:
> 
> > > > By iterating over threads instead, it is possible to detect threads that
> > > > are exiting and nominate them for oom kill so they get access to memory
> > > > reserves.
> > >
> > > In fact, PF_EXITING is a sing of *THREAD* exiting, not process. Therefore
> > > PF_EXITING is not a sign of memory freeing in nearly future. If other
> > > CPUs don't try to free memory, prevent oom and waiting makes deadlock.
> > 
> > I agree. I don't understand this patch.
> > 
> 
> Using for_each_process() does not consider threads that have failed to 
> exit after the oom killed parent and, thus, we select another innocent 
> task to kill when we're really just waiting for those threads to exit (and 
> perhaps they need memory reserves in the exit path) or, in the worst case, 
> panic if there is nothing else eligible.
> 
> The end result is that without this patch, we sometimes unnecessarily 
> panic (and "sometimes" is defined as "many machines" for us) when nothing 
> else is eligible for kill within an oom cpuset yet doing a 
> do_each_thread() over that cpuset shows threads of previously oom killed 
> parent that have yet to exit.

Only your workload careness don't make any excuse to break other worlds.
Google workload specific patch should be maintained in their. We only want 
to discuss to make world happy.

Guys, Why don't run the test program. Oleg did spnet some times for you.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
