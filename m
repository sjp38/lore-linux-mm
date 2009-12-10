Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 00A776B0047
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 03:45:31 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA8jTQm021249
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 17:45:29 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1260145DE4F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:45:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EA12345DE4C
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:45:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D301A1DB8038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:45:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F8D11DB8037
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:45:25 +0900 (JST)
Date: Thu, 10 Dec 2009 17:42:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
Message-Id: <20091210174230.8367a46c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091210083310.GB6834@elte.hu>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210075454.GB25549@elte.hu>
	<20091210172040.37d259d3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210083310.GB6834@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009 09:33:10 +0100
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > I'm sorry If I miss your point...are you saying remove all mm_counter 
> > completely and remake them under perf ? If so, some proc file 
> > (/proc/<pid>/statm etc) will be corrupted ?
> 
> No, i'm not suggesting that - i'm just suggesting that right now MM 
> stats are not very well suited to be exposed via perf. If we wanted to 
> measure/sample the information in /proc/<pid>/statm it just wouldnt be 
> possible. We have a few events like pagefaults and a few tracepoints as 
> well - but more would be possible IMO.
> 

Ah, ok. More events will be useful.

This patch itself is for reduce(not increase) cache miss in page fault pass..
And counters I'll add is for task monitoring, like ps or top, and for improving
OOM killer. Not for counting events but for showing current _usage_ to users
via procfs or to oom killer.

I'll continue to make an efforts to find better synchronization scheme
rather than adding hook to schedule() but...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
