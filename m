Date: Fri, 6 Apr 2001 19:37:55 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <20010406204713.P28118@athlon.random>
Message-ID: <Pine.LNX.4.21.0104061932300.1374-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Apr 2001, Andrea Arcangeli wrote:
> 
> swap cache also decrease the amount free-swap-space, that will be reclaimed as
> soon as we collect the swap cache. so we must add the swap cache size to the
> amount of virtual memory available (in addition to the in-core pagecachesize)
> to take care of the swap side. I suggested that as the fix for the failed
> malloc issue to the missioncritical guys when they asked me about that.

swapper_space.nrpages, that's neat, but I insist it's not right.
You're then double counting into "free" all the swap cache pages
(already included in page_cache_size) which correspond to pages
of swap for running processes - erring in the opposite direction
to the present code.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
