Date: Mon, 27 Dec 1999 16:58:08 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.3.32-pre4/SMP still doesn't boot on Compaq Proliant 1600
In-Reply-To: <Pine.LNX.3.96.991214171649.16967A-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.9912271654320.335-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Alexander Viro <viro@math.psu.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 1999, Benjamin C.R. LaHaise wrote:

>Ah, I see what you're talking about.  In theory we make rw_swap_page use
>the page cache operations of the filesystem (or block device) by simply
>relabelling the page from its swap cache entry.  Actually, if we use the
>page cache for block device access, doesn't that mean that we can get rid
>of the swapper_inode completely?  This seems like an obvious way of doing

The swapper_inode only say "I am a swap cache page". Also the
PG_swap_cache bitflag say the same. So we could remove the swapper inode 
even now but that's not a maojor issue.

The swapper inode only deals with the swap cache and the swap cache is not
the right place where to allocate the loop cache.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
