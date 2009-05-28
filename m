Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB966B0082
	for <linux-mm@kvack.org>; Thu, 28 May 2009 15:35:48 -0400 (EDT)
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090523085653.0ad217f8@infradead.org>
References: <20090520183045.GB10547@oblivion.subreption.com>
	 <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu>
	 <20090522113809.GB13971@oblivion.subreption.com>
	 <20090522143914.2019dd47@lxorguk.ukuu.org.uk>
	 <20090522180351.GC13971@oblivion.subreption.com>
	 <20090522192158.28fe412e@lxorguk.ukuu.org.uk>
	 <20090522234031.GH13971@oblivion.subreption.com>
	 <20090523090910.3d6c2e85@lxorguk.ukuu.org.uk>
	 <20090523085653.0ad217f8@infradead.org>
Content-Type: text/plain
Date: Thu, 28 May 2009 21:36:01 +0200
Message-Id: <1243539361.6645.80.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Larry H." <research@subreption.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Sat, 2009-05-23 at 08:56 -0700, Arjan van de Ven wrote:
> On Sat, 23 May 2009 09:09:10 +0100
> Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> 
> > > Enabling SLAB poisoning by default will be a bad idea
> > 
> > Why ?
> > 
> > > I looked for unused/re-usable flags too, but found none. It's
> > > interesting to see SLUB and SLOB have their own page flags. Did
> > > anybody oppose those when they were proposed? 
> > 
> > Certainly they were looked at - but the memory allocator is right at
> > the core of the system rather than an add on.
> > 
> > > > Ditto - which is why I'm coming from the position of an "if we
> > > > free it clear it" option. If you need that kind of security the
> > > > cost should be more than acceptable - especially with modern
> > > > processors that can do cache bypass on the clears.
> > > 
> > > Are you proposing that we should simply remove the confidential
> > > flags and just stick to the unconditional sanitization when the
> > > boot option is enabled? If positive, it will make things more
> > > simple and definitely is better than nothing. I would have (still)
> > > preferred the other old approach to be merged, but whatever works
> > > at this point.
> > 
> > I am because
> > - its easy to merge
> > - its non controversial
> > - it meets the security good practice and means we don't miss any
> >   alloc/free cases
> > - it avoid providing flags to help a trojan identify "interesting"
> > data to acquire
> > - modern cpu memory clearing can be very cheap
> 
> ... and if we zero on free, we don't need to zero on allocate.
> While this is a little controversial, it does mean that at least part of
> the cost is just time-shifted, which means it'll not be TOO bad
> hopefully...

zero on allocate has the advantage of cache hotness, we're going to use
the memory, why else allocate it.

zero on free only causes extra cache evictions for no gain.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
