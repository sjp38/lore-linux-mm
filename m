Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 218516B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 12:53:20 -0500 (EST)
Date: Fri, 8 Jan 2010 09:52:58 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.DEB.2.00.1001081138260.23727@router.home>
Message-ID: <alpine.LFD.2.00.1001080950120.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>  <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>  <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
  <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>  <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>  <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>  <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001051917000.3630@localhost.localdomain>
 <20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain> <1262969610.4244.36.camel@laptop> <alpine.LFD.2.00.1001080911340.7821@localhost.localdomain>
 <alpine.DEB.2.00.1001081138260.23727@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Fri, 8 Jan 2010, Christoph Lameter wrote:
> 
> Can we at least consider a typical standard business server, dual quad
> core hyperthreaded with 16 "cpus"? Cacheline contention will increase
> significantly there.

I bet it won't be a problem. It's when things go cross-socket that they 
suck. So 16 cpu's across two sockets I wouldn't worry about.

> > Because let's face it - if your workload does several million page faults
> > per second, you're just doing something fundamentally _wrong_.
> 
> You may just want to get your app running and its trying to initialize
> its memory in parallel on all threads. Nothing wrong with that.

Umm. That's going to be limited by the memset/memcpy, not the rwlock, I 
bet.

The benchmark in question literally did a single byte write to each page 
in order to show just the kernel component. That really isn't realistic 
for any real load.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
