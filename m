Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A9F796B00E4
	for <linux-mm@kvack.org>; Sat, 30 May 2009 13:46:16 -0400 (EDT)
Date: Sat, 30 May 2009 19:46:44 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530174644.GC20013@elte.hu>
References: <20090523124944.GA23042@elte.hu> <4A187BDE.5070601@redhat.com> <20090527223421.GA9503@elte.hu> <20090528072702.796622b6@lxorguk.ukuu.org.uk> <20090528090836.GB6715@elte.hu> <20090528125042.28c2676f@lxorguk.ukuu.org.uk> <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com> <20090530075033.GL29711@oblivion.subreption.com> <4A20E6CF.8070003@cs.helsinki.fi> <20090530090513.GO29711@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090530090513.GO29711@oblivion.subreption.com>
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Larry H. <research@subreption.com> wrote:

> On 10:57 Sat 30 May     , Pekka Enberg wrote:
> > Larry H. wrote:
> >> Furthermore, selective clearing doesn't solve the roots of the problem.
> >> It's just adding bandages to a wound which never stops bleeding. I
> >> proposed an initial page flag because we could use it later for
> >> unconditional page clearing doing a one line change in a header file.
> >> I see a lot of speculation on what works and what doesn't, but
> >> there isn't much on the practical side of things, yet. I provided test
> >> results that proved some of the comments wrong, and I've referenced
> >> literature which shows the reasoning behind all this. What else can I do
> >> to make you understand you are missing the point here?
> >
> > Hey, if you want to add a CONFIG_ZERO_ALL_MEMORY_PARANOIA thing that can be 
> > disabled, go for it! But you have to find someone else to take the merge 
> > the SLAB bits because, quite frankly, I am not convinced it's worth it. And 
> > the hand waving you're doing here isn't really helping your case, sorry.
> 
> For a second I thought it was Ingo who was writing this e-mail. 
> Apologies about the confusion.

btw., i find this is rather hillarious: you thought it was me 
writing the reply and you answered Pekka's arguments with contempt 
and hand-waving.

Now that you realized that it's the SLAB maintainer you replied to, 
whom you cannot just hand-wave away, you apologize not for the 
bogosity of your argument and not for the concept - but you 
apologize for _thinking it was the wrong person_.

That is a rather dishonest style of discussion.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
