Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CBD5B6005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 16:47:00 -0500 (EST)
Subject: Re: [RFC][PATCH 0/8] Speculative pagefault -v3
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <4B42606F.3000906@redhat.com>
References: <20100104182429.833180340@chello.nl>
	 <4B42606F.3000906@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 04 Jan 2010 22:46:13 +0100
Message-ID: <1262641573.6408.434.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-01-04 at 16:41 -0500, Rik van Riel wrote:
> On 01/04/2010 01:24 PM, Peter Zijlstra wrote:
> > Patch series implementing speculative page faults for x86.
> 
> Fun, but why do we need this?

People were once again concerned with mmap_sem contention on threaded
apps on large machines. Kame-san posted some patches, but I felt they
weren't quite crazy enough ;-)

> What improvements did you measure?

I got it not to crash :-) Although I'd not be surprised if other people
do manage, it needs more eyes.

> I'll take a look over the patches to see whether they're
> sane...

More appreciated, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
