Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 630BA6B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 13:46:27 -0500 (EST)
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Andi Kleen <andi@firstfloor.org>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	<20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
	<20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
	<20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>
	<20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001051917000.3630@localhost.localdomain>
	<20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001052007090.3630@localhost.localdomain>
	<1262969610.4244.36.camel@laptop>
	<alpine.LFD.2.00.1001080911340.7821@localhost.localdomain>
	<alpine.DEB.2.00.1001081138260.23727@router.home>
Date: Fri, 08 Jan 2010 19:46:20 +0100
In-Reply-To: <alpine.DEB.2.00.1001081138260.23727@router.home> (Christoph Lameter's message of "Fri, 8 Jan 2010 11:43:41 -0600 (CST)")
Message-ID: <87my0omo3n.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux-foundation.org> writes:

> Can we at least consider a typical standard business server, dual quad
> core hyperthreaded with 16 "cpus"? Cacheline contention will increase
> significantly there.

This year's standard server will be more like 24-64 "cpus"

Cheating with locks usually doesn't work anymore at these sizes.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
