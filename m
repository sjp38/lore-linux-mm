From: Alan Cox <alan@redhat.com>
Message-Id: <200104091816.f39IGxD16018@devserv.devel.redhat.com>
Subject: Re: [PATCH] swap_state.c thinko
Date: Mon, 9 Apr 2001 14:16:59 -0400 (EDT)
In-Reply-To: <20010406222256.C935@athlon.random> from "Andrea Arcangeli" at Apr 06, 2001 10:22:56 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, Apr 06, 2001 at 12:52:26PM -0700, Linus Torvalds wrote:
> > vm_enough_memory() is a heuristic, nothing more. We want it to reflect
> > _some_ view of reality, but the Linux VM is _fundamentally_ based on the
> > notion of over-commit, and that won't change. vm_enough_memory() is only
> > meant to give a first-order appearance of not overcommitting wildly. It
> > has never been anything more than that.
> 
> 200% agreed.

Given that strict address space management is not that hard would you 
accept patches to allow optional non-overcommit in 2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
