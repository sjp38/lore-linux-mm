Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F364E6005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 19:31:55 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o050VrEU007722
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Jan 2010 09:31:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AB4645DE61
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:31:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BEC345DE4E
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:31:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FB721DB803E
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:31:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CEB0E1DB803A
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:31:52 +0900 (JST)
Date: Tue, 5 Jan 2010 09:28:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/8] Speculative pagefault -v3
Message-Id: <20100105092836.a7feb26c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1001041558350.17041@router.home>
References: <20100104182429.833180340@chello.nl>
	<4B42606F.3000906@redhat.com>
	<alpine.DEB.2.00.1001041558350.17041@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 2010 15:59:45 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Mon, 4 Jan 2010, Rik van Riel wrote:
> 
> > Fun, but why do we need this?
> >
> > What improvements did you measure?
> 
> If it measures up to Kame-sans approach then the possible pagefault rate
> will at least double ...
> 
On 4-core/2 socket machine ;)

More than page fault rate, important fact is that we can reduce cache contention
by skipping mmap_sem in some situation.

And I think we have some chances.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
