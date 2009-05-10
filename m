Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A8A876B0099
	for <linux-mm@kvack.org>; Sun, 10 May 2009 07:44:49 -0400 (EDT)
Date: Sun, 10 May 2009 19:44:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
	class  citizen
Message-ID: <20090510114454.GA8891@localhost>
References: <20090508081608.GA25117@localhost> <20090508125859.210a2a25.akpm@linux-foundation.org> <20090508230045.5346bd32@lxorguk.ukuu.org.uk> <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com> <20090510092053.GA7651@localhost> <2f11576a0905100229m2c5e6a67md555191dc8c374ae@mail.gmail.com> <20090510100335.GC7651@localhost> <2f11576a0905100315j2c810e96mc29b84647dc565c2@mail.gmail.com> <20090510112149.GA8633@localhost> <2f11576a0905100439u38c8bccak355ec23953950d6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0905100439u38c8bccak355ec23953950d6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, May 10, 2009 at 07:39:12PM +0800, KOSAKI Motohiro wrote:
> >> > So if that's what they want, let them have it to their heart's content.
> >> >
> >> > You know it's normal for many users/apps to care only about the result.
> >> > When they want something but cannot get it from the smarter version of
> >> > PROT_EXEC heuristics, they will go on to devise more complicated tricks.
> >> >
> >> > In the end both sides loose.
> >> >
> >> > If the abused case is important enough, then let's introduce a feature
> >> > to explicitly prioritize the pages. But let's leave the PROT_EXEC case
> >> > simple.
> >>
> >> No.
> >> explicit priotize mechanism don't solve problem anyway. application
> >> developer don't know end-user environment.
> >> they can't mark proper page priority.
> >
> > So it's simply wrong for an application to prioritize itself and is
> > not fair gaming and hence should be blamed. I doubt any application
> > aimed for a wide audience will do this insane hack.
> 
> There already are.
> some application don't interest strict PROT_ setting.

> They always use mmap(PROT_READ | PROT_WRITE | PROT_EXEC) for anycase.
> Please google it. you can find various example.
 
How widely is PROT_EXEC abused? Would you share some of your google results?

Thanks,
Fengguang

> 
> > But specific
> > targeted applications are more likely to do all tricks which fits
> > their needs&environment, and likely they are doing so for good reasons
> > and are aware of the consequences.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
