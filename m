Date: Tue, 3 Apr 2001 19:11:39 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] Reclaim orphaned swap pages 
In-Reply-To: <Pine.LNX.4.21.0104030919080.12558-100000@jerrell.lowell.mclinux.com>
Message-ID: <Pine.LNX.4.21.0104031910450.7175-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Jerrell <jerrell@missioncriticallinux.com>
Cc: Szabolcs Szakacsits <szaka@f-secure.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2001, Richard Jerrell wrote:

> > > That's not really what I'm getting at.  Currently if you run a memory
> > > intensive application, quit after it's pages are on an lru, and try to
> > > restart, you won't be able to get the memory.  This is because pages which
> > > are sitting around in the swap cache are not counted as free, and they
> > > should be, because they are freeable.
> > 
> > No. Dirty swapcache pages which have pte's referencing them are not
> > freeable.
> 
> If you quit the application, it no longer has ptes which are referencing
> the page.  If, in addition, this page no longer has any ptes referencing
> it, then it is wasting space.  That is why we free the page (providing
> that the swap entry is not shared either).  Otherwise, you will run out of
> memory because everything is stuck in the swap cache until it gets
> laundered, regardless of whether anyone is still referencing the
> page.  That is not a good thing, which is what the patch fixes.

Right.

But you should not count _all_ swapcache pages as freeable. 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
