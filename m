Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA11457
	for <linux-mm@kvack.org>; Tue, 9 Dec 1997 12:31:07 -0500
Date: Tue, 9 Dec 1997 18:10:37 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: Ideas for memory management hackers.
In-Reply-To: <199712091611.RAA05335@boole.fs100.suse.de>
Message-ID: <Pine.LNX.3.91.971209180740.4287C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 1997, Dr. Werner Fink wrote:

> > 
> > I have integrated mmap aging in kswapd, without the need for
> > vhand, in 2.1.71 (experimental). As ppp isn't working in 2.1.71
> > I'm back to 2.1.66 now, but I have seen kswapd use over 10% of
> > CPU for short times now :(
> 
> Q: if ageing is now a separate part the CPU usage of freeing a page
>    in kswapd and __get_free_pages should drop, shouldn't it?

In this new patch, aging is not a separate process, because
vhand has a design flaw in it :(( (I think).
The page->referenced flag is not updated by the mmu, instead
it updates the pte->accessed flag... Now vhand can't handle
normal user pages (this explains the higher swap usage) and
they are swapped more often, actually, they are swapped by a
second chance fifo algorithm now, so nobody noticed decreased
performance...
> 
> > I think I'll send it to Linus (together with Zlatko's
> > big-order hack) as a bug-fix (we're on feature-freeze after all:)
> > for inclusion in 2.1.72...
> > 
> > opinions please,
> 
> Q2: Is the patch available (ftp/http) for testing/reading?

RSN...


Rik.

--
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
