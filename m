Date: Fri, 6 Apr 2001 20:03:08 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <20010406211416.B785@athlon.random>
Message-ID: <Pine.LNX.4.21.0104061954470.1407-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Apr 2001, Andrea Arcangeli wrote:
> On Fri, Apr 06, 2001 at 09:09:08PM +0200, Andrea Arcangeli wrote:
> > We always overstimate anyways, we have to because we don't have information
> > about the really freeable memory (think at the buffer cache pinned in the
> 
> ah, and btw, even if we would have information about the really freeable memory
> in the cache and swap cache that would still useless in real life because we
> don't reserve memory for the previous malloc calls (endless overcommit
> discussion), so allocation could still fail during page fault and process will
> have to be killed the linux way.

How indelicate you are!  I've been careful to avoid all mention of that...
Seriously, there's good debate to have there, but it's another issue
(and I don't think the drawbacks of the overcommit strategy excuse
sloppy accounting on its own terms).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
