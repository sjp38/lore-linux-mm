Date: Fri, 6 Apr 2001 19:53:30 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <20010406210908.A785@athlon.random>
Message-ID: <Pine.LNX.4.21.0104061950390.1397-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Apr 2001, Andrea Arcangeli wrote:
> On Fri, Apr 06, 2001 at 07:37:55PM +0100, Hugh Dickins wrote:
> > swapper_space.nrpages, that's neat, but I insist it's not right.
> > You're then double counting into "free" all the swap cache pages
> > (already included in page_cache_size) which correspond to pages
> > of swap for running processes - erring in the opposite direction
> > to the present code.
> 
> The whole point is that errirng in the opposite direction is perfectly fine,
> that's expected.  Understimating is a bug instead. Period.
> 
> We always overstimate anyways, we have to because we don't have information
> about the really freeable memory (think at the buffer cache pinned in the
> superblock metadata of ext2, do you expect to be able to reclaim it somehow?).

Well, that's an interesting point of view... but if it's so okay
to overestimate, couldn't we simplify vm_enough_pages() somewhat?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
