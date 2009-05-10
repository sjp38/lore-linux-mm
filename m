Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B5EDB6B0089
	for <linux-mm@kvack.org>; Sun, 10 May 2009 07:38:36 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so1203162yxh.26
        for <linux-mm@kvack.org>; Sun, 10 May 2009 04:39:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090510112149.GA8633@localhost>
References: <20090507151039.GA2413@cmpxchg.org>
	 <20090508081608.GA25117@localhost>
	 <20090508125859.210a2a25.akpm@linux-foundation.org>
	 <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	 <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	 <20090510092053.GA7651@localhost>
	 <2f11576a0905100229m2c5e6a67md555191dc8c374ae@mail.gmail.com>
	 <20090510100335.GC7651@localhost>
	 <2f11576a0905100315j2c810e96mc29b84647dc565c2@mail.gmail.com>
	 <20090510112149.GA8633@localhost>
Date: Sun, 10 May 2009 20:39:12 +0900
Message-ID: <2f11576a0905100439u38c8bccak355ec23953950d6@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

>> > So if that's what they want, let them have it to their heart's content.
>> >
>> > You know it's normal for many users/apps to care only about the result.
>> > When they want something but cannot get it from the smarter version of
>> > PROT_EXEC heuristics, they will go on to devise more complicated tricks.
>> >
>> > In the end both sides loose.
>> >
>> > If the abused case is important enough, then let's introduce a feature
>> > to explicitly prioritize the pages. But let's leave the PROT_EXEC case
>> > simple.
>>
>> No.
>> explicit priotize mechanism don't solve problem anyway. application
>> developer don't know end-user environment.
>> they can't mark proper page priority.
>
> So it's simply wrong for an application to prioritize itself and is
> not fair gaming and hence should be blamed. I doubt any application
> aimed for a wide audience will do this insane hack.

There already are.
some application don't interest strict PROT_ setting.

They always use mmap(PROT_READ | PROT_WRITE | PROT_EXEC) for anycase.
Please google it. you can find various example.


> But specific
> targeted applications are more likely to do all tricks which fits
> their needs&environment, and likely they are doing so for good reasons
> and are aware of the consequences.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
