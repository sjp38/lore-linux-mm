Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6D5F06B004D
	for <linux-mm@kvack.org>; Sat,  6 Jun 2009 02:45:38 -0400 (EDT)
Date: Fri, 5 Jun 2009 15:15:44 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090605131544.GA1376@ucw.cz>
References: <20090522073436.GA3612@elte.hu> <20090530054856.GG29711@oblivion.subreption.com> <1243679973.6645.131.camel@laptop> <4A211BA8.8585.17B52182@pageexec.freemail.hu> <1243689707.6645.134.camel@laptop> <20090530153023.45600fd2@lxorguk.ukuu.org.uk> <1243694737.6645.142.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243694737.6645.142.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu, "Larry H." <research@subreption.com>, Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi!

> > > Right, so the whole point is to minimize the impact of actual bugs,
> > > right? So why not focus on fixing those actual bugs? Can we create tools
> > > to help us find such bugs faster? We use sparse for a lot of static
> > > checking, we create things like lockdep and kmemcheck to dynamically
> > > find trouble.
> > > 
> > > Can we instead of working around a problem, fix the actual problem?
> > 
> > Why do cars have crashworthiness and seatbelts ? Why not fix the actual
> > problem (driving errors) ? I mean lets face it they make the vehicle
> > heavier, less fuel efficient, less fun and more annoying to use.
> 
> We can't find every crash bug either, yet we still ship the kernel and
> people actually use it too.
> 
> What makes these security bugs so much more important than all the other
> ones?

Impact of normal bug is crash -- solved by reboot.

Impact of nasty bug is data corruption -- very rare, solved by
reinstall.

Impact of security bug is 'it is not your machine any more' (or worse,
as in 'it is not your bank account any more') -- reinstall needed,
too, and maybe worse.

So yes, I believe we should do some memory clearing.

> As long as that openoffice or firefox instance keeps running, there's
> nothing in the world the kernel can do to make it more secure.

True.

> If you really write documents that sekrit you simply shouldn't be using
> such software but use an editor that is written by people as paranoid as
> seems to be advocated here.

I may avoid openoffice but I'd still like vi on linux system. 
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
