Date: Fri, 6 Apr 2001 21:14:16 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] swap_state.c thinko
Message-ID: <20010406211416.B785@athlon.random>
References: <20010406204713.P28118@athlon.random> <Pine.LNX.4.21.0104061932300.1374-100000@localhost.localdomain> <20010406210908.A785@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010406210908.A785@athlon.random>; from andrea@suse.de on Fri, Apr 06, 2001 at 09:09:08PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 06, 2001 at 09:09:08PM +0200, Andrea Arcangeli wrote:
> We always overstimate anyways, we have to because we don't have information
> about the really freeable memory (think at the buffer cache pinned in the

ah, and btw, even if we would have information about the really freeable memory
in the cache and swap cache that would still useless in real life because we
don't reserve memory for the previous malloc calls (endless overcommit
discussion), so allocation could still fail during page fault and process will
have to be killed the linux way.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
