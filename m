Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 06CFB6B004D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 22:56:26 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n542uJVG015614
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Jun 2009 11:56:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89F7E45DE51
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:56:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 549BB45DD79
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:56:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DC5D1DB803F
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:56:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E56501DB803E
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:56:18 +0900 (JST)
Date: Thu, 4 Jun 2009 11:54:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: swapoff throttling and speedup?
Message-Id: <20090604115448.c1b434ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A2734BA.7080004@gmail.com>
References: <4A26AC73.6040804@gmail.com>
	<20090604110456.90b0ebcb.kamezawa.hiroyu@jp.fujitsu.com>
	<4A2734BA.7080004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joel Krauska <jkrauska@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 03 Jun 2009 19:43:06 -0700
Joel Krauska <jkrauska@gmail.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> >> 1. Has anyone tried making a nicer swapoff?
> >> Right now swapoff can be pretty aggressive if the system is otherwise
> >> heavily loaded.  On systems that I need to leave running other jobs,
> >> swapoff compounds the slowness of the system overall by burning up
> >> a single CPU and lots of IO
> >>
> >> I wrote a perl wrapper that briefly runs swapoff 
> >> and then kills it, but it would seem more reasonable to have a knob
> >> to make swapoff less aggressive. (max kb/s, etc)  
> >>
> >> It looked to me like the swapoff code was immediately hitting kernel 
> >> internals instead of doing more lifting itself (and making it 
> >> obvious where I could insert some sleeps)
> >>
> 
> I find I need a slower swapoff when a system that's already running very hot
> needs to be recovered from lots of swapping without overly impacting the other
> running processes.
> 
> The bulk of the work is still being done in normal RAM, and the overhead
> of consuming an entire CPU just for swapoff degrades my other running processes.
> 
> > How about throttling swapoff's cpu usage by cpu scheduler cgroup ?
> > No help ?
> 
> I think swapoff is all done as systemcalls, not in userspace, so I'm not
> sure that cgroups would apply here.  (granted I had never heard of control
> groups until just now...)
> 
IIUC, some "cond_resched()" , means "reschedule if necessary", are inserted to
swapoff's main loop. Then, limiting usage of cpu may have effects, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
