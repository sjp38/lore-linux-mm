Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B554A6B008C
	for <linux-mm@kvack.org>; Sun, 10 May 2009 06:14:49 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so1194944yxh.26
        for <linux-mm@kvack.org>; Sun, 10 May 2009 03:15:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090510100335.GC7651@localhost>
References: <1241432635.7620.4732.camel@twins>
	 <20090507151039.GA2413@cmpxchg.org>
	 <20090507134410.0618b308.akpm@linux-foundation.org>
	 <20090508081608.GA25117@localhost>
	 <20090508125859.210a2a25.akpm@linux-foundation.org>
	 <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	 <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	 <20090510092053.GA7651@localhost>
	 <2f11576a0905100229m2c5e6a67md555191dc8c374ae@mail.gmail.com>
	 <20090510100335.GC7651@localhost>
Date: Sun, 10 May 2009 19:15:02 +0900
Message-ID: <2f11576a0905100315j2c810e96mc29b84647dc565c2@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

>> >> >> The patch seems reasonable but the changelog and the (non-existent)
>> >> >> design documentation could do with a touch-up.
>> >> >
>> >> > Is it right that I as a user can do things like mmap my database
>> >> > PROT_EXEC to get better database numbers by making other
>> >> > stuff swap first ?
>> >> >
>> >> > You seem to be giving everyone a "nice my process up" hack.
>> >>
>> >> How about this?
>> >
>> > Why it deserves more tricks? PROT_EXEC pages are rare.
>> > If user space is to abuse PROT_EXEC, let them be for it ;-)
>>
>> yes, typicall rare.
>> tha problem is, user program _can_ use PROT_EXEC for get higher priority
>> ahthough non-executable memory.
>
> - abuses should be rare
> - large scale abuses will be even more rare,
> - the resulted vmscan overheads are the *expected* side effect
> - the side effects are still safe

Who expect?
The fact is, application developer decide to use PROT_EXEC, but side-effect
cause end-user, not application developer.

In general, side-effect attack mistaked guy, it's no problem. They can
do it their own risk.
but We know application developer and administrator are often different person.


> So if that's what they want, let them have it to their heart's content.
>
> You know it's normal for many users/apps to care only about the result.
> When they want something but cannot get it from the smarter version of
> PROT_EXEC heuristics, they will go on to devise more complicated tricks.
>
> In the end both sides loose.
>
> If the abused case is important enough, then let's introduce a feature
> to explicitly prioritize the pages. But let's leave the PROT_EXEC case
> simple.

No.
explicit priotize mechanism don't solve problem anyway. application
developer don't know end-user environment.
they can't mark proper page priority.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
