Date: Tue, 2 May 2000 17:45:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <Pine.LNX.4.21.0005030228300.3498-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10005021743270.811-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>


On Wed, 3 May 2000, Andrea Arcangeli wrote:
> 
> Comments?

Note that as far as I remember, the swap entry thing was introduced
because get_swap_entry() was slow and took up a lot of time.

Let's see if we can just simply drop the swap entry bit, and if required
possibly speed up get_swap_entry some other way. The swap cache access
patterns may be different enough that it might not be that noticeable, for
example (or it might be worse, who knows?)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
