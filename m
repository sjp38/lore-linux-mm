Date: Tue, 31 Jul 2001 10:16:48 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: strange locking __find_get_swapcache_page()
In-Reply-To: <3B668629.34797B3F@zip.com.au>
Message-ID: <Pine.LNX.4.33.0107311016130.1188-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2001, Andrew Morton wrote:
>
> read_swap_cache_async()?  All code paths in that area are
> under lock_kernel().

Ugh. But yes, that would certainly fix the race.

Let's leave it, and fix it for real in 2.5.x

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
