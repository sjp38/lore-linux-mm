Date: Mon, 23 Apr 2001 18:54:17 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: Re: [patch] swap-speedup-2.4.3-A2
In-Reply-To: <Pine.LNX.4.21.0104231011070.13206-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.30.0104231852130.394-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, Szabolcs Szakacsits <szaka@f-secure.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Apr 2001, Linus Torvalds wrote:

> The above is NOT how the page cache works. Or if some part of the page
> cache works that way, then it is a BUG. You must NEVER allow multiple
> outstanding reads from the same location - that implies that you're
> doing something wrong, and the system is doing too much IO.

you are right, the pagecache does it correctly, i've just re-checked all
places.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
