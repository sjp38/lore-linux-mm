Date: Wed, 15 Aug 2001 15:30:02 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.21.0108151747570.26574-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0108151528180.887-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Marcelo Tosatti wrote:
>
>  __GFP_IO is not going to help us that much on anon intensive workloads
> (eg swapoff). Remember we are _never_ going to block on buffer_head's of
> on flight swap pages because we can't see them in page_launder(). (if a
> page is locked, we simply skip it)

Note that that is what we have the page_alloc (and buffer head) reserves
for - and it doesn't take that much to get the ball rolling. Certainly not
even close to our low-water-marks.. And once it snowballs it _does_ help
that people call page_launder().

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
