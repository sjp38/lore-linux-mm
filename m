Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5988B6007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:15:22 -0500 (EST)
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Andi Kleen <andi@firstfloor.org>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105054536.44bf8002@infradead.org>
Date: Tue, 05 Jan 2010 15:15:15 +0100
In-Reply-To: <20100105054536.44bf8002@infradead.org> (Arjan van de Ven's message of "Tue, 5 Jan 2010 05:45:36 -0800")
Message-ID: <87637gd4ek.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Arjan van de Ven <arjan@infradead.org> writes:

> On Mon, 04 Jan 2010 19:24:35 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
>> Generic speculative fault handler, tries to service a pagefault
>> without holding mmap_sem.
>
>
> while I appreciate the goal of reducing contention on this lock...
> wouldn't step one be to remove the page zeroing from under this lock?
> that's by far (easily by 10x I would guess) the most expensive thing
> that's done under the lock, and I would expect a first order of
> contention reduction just by having the zeroing of a page not done
> under the lock...

The cache line bouncing of the shared cache lines hurts too.

I suspect fixing this all properly will need some deeper changes.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
