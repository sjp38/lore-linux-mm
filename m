Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E6A2F6007BA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 03:35:51 -0500 (EST)
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <28c262361001042209k7241dd38l3d51d230e7b68a5@mail.gmail.com>
References: <20100104182429.833180340@chello.nl>
	 <20100104182813.753545361@chello.nl>
	 <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	 <alpine.LFD.2.00.1001042038110.3630@localhost.localdomain>
	 <28c262361001042209k7241dd38l3d51d230e7b68a5@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Jan 2010 09:35:21 +0100
Message-ID: <1262680521.2400.25.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-01-05 at 15:09 +0900, Minchan Kim wrote:

> Couldn't we synchronize rcu in that cases(munmap, exit and so on)?
> It can delay munap and exit but it would be better than handling them by more
> complicated things, I think. And both cases aren't often cases so we
> can achieve advantage than disadvantage?

Sadly there are programs that mmap()/munmap() at a staggering rate
(clamav comes to mind), so munmap() performance is important too.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
