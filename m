Date: Mon, 2 Sep 2002 18:15:04 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: About the free page pool
In-Reply-To: <3D73D666.9F3A8B0B@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209021812420.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Sep 2002, Andrew Morton wrote:

> Well, I'm at a bit of a loss to understand what the objective
> of all this is.  Is it so that we can effectively increase the
> cache size, by not "wasting" all that free memory?

This is the main goal, yes.  It is worth noting that it also
works in the other direction, we can simply increase the clean
target to something large if we have a high allocation rate
because it doesn't waste memory to clean pages earlier.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
