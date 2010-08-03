Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ABE236008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 03:26:37 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o737WSpl024785
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 16:32:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B751745DE79
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 16:32:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EE5045DE7A
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 16:32:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C0FE1DB803F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 16:32:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B08701DB8045
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 16:32:27 +0900 (JST)
Date: Tue, 3 Aug 2010 16:27:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100803162738.52858530.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100803162111.2f8dfded.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
	<20100802134312.c0f48615.akpm@linux-foundation.org>
	<20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com>
	<20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com>
	<20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021850400.19184@chino.kir.corp.google.com>
	<20100803110534.e3e7a697.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021953520.27231@chino.kir.corp.google.com>
	<20100803121146.cf35b7ed.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008022117200.4146@chino.kir.corp.google.com>
	<20100803133255.deb5c208.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008030016590.20849@chino.kir.corp.google.com>
	<20100803162111.2f8dfded.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 16:21:11 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 3 Aug 2010 00:23:32 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > > Especially with memcg, it just shows a _broken_ value.
> > > 
> > 
> > Not at all, the user knows what tasks are attached to the memcg and can 
> > easily determine which task is going to be killed when it ooms: simply 
> > iterate through the memcg tasklist, check /proc/pid/oom_score, and sort.
> > 
> 
> And finds 
> 	at system oom,  process A is killed.
> 	at memcg oom, process B is killed.
> 
> funny non-deteministic interace, aha.
> 

I said
	- you have beutiful legs. (new logic of oom calculation)
	- but your face is ugly	  (new oom_score_adj)
	then
	- I bought a mask for you (oom_disable for memcg.)

Then, please don't use your time for convince me your face is beutiful.
It's waste of time.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
