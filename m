Date: Mon, 18 Feb 2002 18:11:49 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] reduce struct_page size
In-Reply-To: <Pine.LNX.4.33L.0202182258550.1930-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.33.0202181806340.24597-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 18 Feb 2002, Rik van Riel wrote:
>
> o page->zone is shrunk from a pointer to an index into a small
>   array of zones ... this means we have space for 3 more chars
>   in the struct page to other stuff (say, page->age)

Why not put "page->zone" into the page flags instead? That one has to be
unsigned long anyway for atomicity reasons, and we have tons of free space
for "a few bits" (even if you need something like 2 bits ber node, and
have several nodes, we've got a minimum of 16 bits free right now and I
doubt we'll ever see more than a few nodes on any 32-bit architecture, so
we're not likely to need more than 8 bits tops on any 32-bit arch, and on
64-bit archs we have tons more bits).

The patch looks good, it's just silly to say that you made "struct page"
smaller, and then waste four bytes.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
