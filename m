Date: Mon, 9 Apr 2001 20:45:51 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] swap_state.c thinko
Message-ID: <20010409204551.C8138@athlon.random>
References: <20010406222256.C935@athlon.random> <200104091816.f39IGxD16018@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200104091816.f39IGxD16018@devserv.devel.redhat.com>; from alan@redhat.com on Mon, Apr 09, 2001 at 02:16:59PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 09, 2001 at 02:16:59PM -0400, Alan Cox wrote:
> > On Fri, Apr 06, 2001 at 12:52:26PM -0700, Linus Torvalds wrote:
> > > vm_enough_memory() is a heuristic, nothing more. We want it to reflect
> > > _some_ view of reality, but the Linux VM is _fundamentally_ based on the
> > > notion of over-commit, and that won't change. vm_enough_memory() is only
> > > meant to give a first-order appearance of not overcommitting wildly. It
> > > has never been anything more than that.
> > 
> > 200% agreed.
> 
> Given that strict address space management is not that hard would you 
> accept patches to allow optional non-overcommit in 2.5

Since we are not able to estimate how much cache is really freeable a simple
early implementation will have to shrink the cache at mmap time, instead of
page fault time and that should be acceptable to the people who needs it.

I suggest three modes:

1)	non overcommit (optional)
2)	2.4 default (default)
3)	vm_enough_memory always returns 1, equivalent to 2.4 with overcommit
	set to 1 (optional)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
