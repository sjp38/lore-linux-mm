Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 15574600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:49:29 -0500 (EST)
Message-Id: <20100104182429.833180340@chello.nl>
Date: Mon, 04 Jan 2010 19:24:29 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 0/8] Speculative pagefault -v3
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Patch series implementing speculative page faults for x86.

Still needs lots of things sorted, like:

  - call_srcu()
  - ptl, irq and tlb-flush
  - a 2nd VM_FAULT_LOCK? return code to distuinguish between
    simple retry and must take mmap_sem semantics?

Comments?
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
