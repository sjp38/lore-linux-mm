Date: Fri, 6 Apr 2001 21:09:08 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] swap_state.c thinko
Message-ID: <20010406210908.A785@athlon.random>
References: <20010406204713.P28118@athlon.random> <Pine.LNX.4.21.0104061932300.1374-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0104061932300.1374-100000@localhost.localdomain>; from hugh@veritas.com on Fri, Apr 06, 2001 at 07:37:55PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 06, 2001 at 07:37:55PM +0100, Hugh Dickins wrote:
> swapper_space.nrpages, that's neat, but I insist it's not right.
> You're then double counting into "free" all the swap cache pages
> (already included in page_cache_size) which correspond to pages
> of swap for running processes - erring in the opposite direction
> to the present code.

The whole point is that errirng in the opposite direction is perfectly fine,
that's expected.  Understimating is a bug instead. Period.

We always overstimate anyways, we have to because we don't have information
about the really freeable memory (think at the buffer cache pinned in the
superblock metadata of ext2, do you expect to be able to reclaim it somehow?).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
