Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 08A4D6005A4
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 01:24:46 -0500 (EST)
Received: by pxi5 with SMTP id 5so11172004pxi.12
        for <linux-mm@kvack.org>; Mon, 04 Jan 2010 22:24:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100105150932.ab2e6820.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100104182429.833180340@chello.nl>
	 <20100104182813.753545361@chello.nl>
	 <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	 <alpine.LFD.2.00.1001042038110.3630@localhost.localdomain>
	 <28c262361001042209k7241dd38l3d51d230e7b68a5@mail.gmail.com>
	 <20100105150932.ab2e6820.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 5 Jan 2010 15:24:45 +0900
Message-ID: <28c262361001042224u44bad2e8r8eafdbdff673076a@mail.gmail.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 5, 2010 at 3:09 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 5 Jan 2010 15:09:47 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>> My humble opinion is following as.
>>
>> Couldn't we synchronize rcu in that cases(munmap, exit and so on)?
>> It can delay munap and exit but it would be better than handling them by more
>> complicated things, I think. And both cases aren't often cases so we
>> can achieve advantage than disadvantage?
>>
>
> In most case, a program is single threaded. And sychronize_rcu() in unmap path
> just adds very big overhead.

Yes.
I suggested you that consider single-thread app's regression, please. :)

First I come to my head is we can count number of thread.
Yes. thread number is a not good choice.

As a matter of fact, I want to work it adaptively.
If the process start to have many threads, speculative page fault turn
on or turn off.
I know it's not easy. I hope other guys have good ideas.

>
> Thanks,
> -Kame
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
