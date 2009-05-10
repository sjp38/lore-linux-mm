Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 699D76B009F
	for <linux-mm@kvack.org>; Sun, 10 May 2009 08:39:22 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1208020ywm.26
        for <linux-mm@kvack.org>; Sun, 10 May 2009 05:39:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1241957948.9562.2.camel@laptop>
References: <20090508081608.GA25117@localhost>
	 <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	 <20090510092053.GA7651@localhost>
	 <2f11576a0905100229m2c5e6a67md555191dc8c374ae@mail.gmail.com>
	 <20090510100335.GC7651@localhost>
	 <2f11576a0905100315j2c810e96mc29b84647dc565c2@mail.gmail.com>
	 <20090510112149.GA8633@localhost>
	 <2f11576a0905100439u38c8bccak355ec23953950d6@mail.gmail.com>
	 <20090510114454.GA8891@localhost> <1241957948.9562.2.camel@laptop>
Date: Sun, 10 May 2009 21:39:58 +0900
Message-ID: <2f11576a0905100539l1512170oc64f7aee2864e8d5@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

>> > They always use mmap(PROT_READ | PROT_WRITE | PROT_EXEC) for anycase.
>> > Please google it. you can find various example.
>>
>> How widely is PROT_EXEC abused? Would you share some of your google results?
>
> That's a security bug right there and should be fixed regardless of our
> heuristics.

Yes, should be. but it's not security issue. it doesn't make any security hole.
Plus, this claim doesn't help to solve end-user problems.

I think the basic concept of the patch is right.
  - executable mapping is important for good latency
  - executable file is relatively small

The last problem is, The patch assume executable mappings is rare, but
it isn't guranteed.
How do we separate truth executable mapping and mis-used PROT_EXEC usage?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
