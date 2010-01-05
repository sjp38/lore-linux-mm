Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAAF6B0099
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 12:25:38 -0500 (EST)
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
	<alpine.LFD.2.00.1001050810380.3630@localhost.localdomain>
Date: Tue, 05 Jan 2010 18:25:32 +0100
In-Reply-To: <alpine.LFD.2.00.1001050810380.3630@localhost.localdomain> (Linus Torvalds's message of "Tue, 5 Jan 2010 08:14:51 -0800 (PST)")
Message-ID: <87wrzwbh0z.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:
>
> etc, because the x86-64 code has obviously never seen the optimized 
> call-paths, and they need the asm wrappers for full semantics.

iirc Andrea ran benchmarks at some point and it didn't make too much 
difference on the systems back then (K8 era). Given K8 has fast atomics.

> Oh well. Somebody who is bored might look at trying to make the wrapper 
> code in arch/x86/lib/semaphore_32.S work on x86-64 too. It should make the 
> successful rwsem cases much faster.

Maybe, maybe not.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
