Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3BA8D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 05:26:02 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id p189b2QK025967
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 15:07:02 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p18APsUd4075706
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 15:55:55 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p18APsFJ019856
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 21:25:54 +1100
Date: Tue, 8 Feb 2011 15:55:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-ID: <20110208102553.GR27729@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
 <20110208105553.76cfe424.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1102071808280.16931@chino.kir.corp.google.com>
 <20110208111351.93c6d048.kamezawa.hiroyu@jp.fujitsu.com>
 <20110208112041.a9986f09.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1102071836030.17774@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1102071836030.17774@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

* David Rientjes <rientjes@google.com> [2011-02-07 18:37:30]:

> On Tue, 8 Feb 2011, KAMEZAWA Hiroyuki wrote:
> 
> > And write this fact:
> > 
> >      A
> >     /
> >    B
> >   /
> >  C
> > 
> > When 
> >   A.memory_oom_delay=1sec. 
> >   B.memory_oom_delay=500msec
> >   C.memory_oom_delay=200msec
> > 
> > If there are OOM in group C, C's oom_kill will be delayed for 200msec and
> > a task in group C will be killed. 
> > 
> > If there are OOM in group B, B's oom_kill will be delayed for 200msec and
> > a task in group B or C will be killed.
> > 
> > If there are OOM in group A, A's oom_kill will be delayed for 1sec and
> > a task in group A,B or C will be killed.
> > 
> > oom_killer in the hierarchy is serialized by lock and happens one-by-one
> > for avoiding a serial kill. So, above delay can be stacked. 
> > 
> 
> Ok, I'll add this to the comment that says changing 
> memory.oom_delay_millisecs does so for all children as well that was 
> already added in this version of the patch.
> 
> I'll wait a couple days to see if Balbir or Daisuke have any additional 
> comments.
>

The patches look good to me from last time, Kamezawa-San had these
comments even last time. I am OK with the changes proposed.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
