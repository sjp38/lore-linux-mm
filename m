Date: Fri, 6 Apr 2001 11:57:20 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.21.0104061849290.1331-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.31.0104061153350.12081-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 6 Apr 2001, Hugh Dickins wrote:
>
> It is, of course, remotely conceivable that I'm confused, but...
> I realize that the page cache pages (including those of swap)
> are already added into "free" by vm_enough_memory().  But it's also
> adding in nr_swap_pages

.. Ahh. Right you are. We did not just move it from the "free page" to the
"swap cache", we also didn't release the space in the actual swap space
bitmaps, and you're right, that certainly changes the accounting.

Mea culpa. Ideas?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
