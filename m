Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1BB646005A4
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 01:12:56 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o056CqOh027101
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Jan 2010 15:12:52 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C2CA45DE66
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 15:12:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3F2745DE63
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 15:12:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C8A791DF8001
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 15:12:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 725C3EF8005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 15:12:51 +0900 (JST)
Date: Tue, 5 Jan 2010 15:09:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100105150932.ab2e6820.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361001042209k7241dd38l3d51d230e7b68a5@mail.gmail.com>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	<alpine.LFD.2.00.1001042038110.3630@localhost.localdomain>
	<28c262361001042209k7241dd38l3d51d230e7b68a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jan 2010 15:09:47 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:
> My humble opinion is following as.
> 
> Couldn't we synchronize rcu in that cases(munmap, exit and so on)?
> It can delay munap and exit but it would be better than handling them by more
> complicated things, I think. And both cases aren't often cases so we
> can achieve advantage than disadvantage?
> 

In most case, a program is single threaded. And sychronize_rcu() in unmap path
just adds very big overhead.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
