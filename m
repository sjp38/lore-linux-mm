Date: Wed, 15 Aug 2001 17:50:30 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.21.0108151943040.26574-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0108151749130.1150-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Marcelo Tosatti wrote:
>
> Try this: Add a "priority" argument to page_launder(), and make the
> refill_freelist() call to page_launder() use a very low priority, and keep
> DEF_PRIORITY in the other callers.

No. Don't do this. That is 100% equivalent to just calling the function
multiple times.

And you shouldn't do that EITHER. Not alone. There may be other forms of
imbalance, and trying to address just one is bad.

Look at do_try_to_free_page(). Read it. Grok it.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
