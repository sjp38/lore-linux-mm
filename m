Date: Thu, 13 Jan 2000 16:52:47 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.21.0001140128510.3816-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001131650520.2250-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@chiara.csoma.elte.hu>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 14 Jan 2000, Andrea Arcangeli wrote:
> 
> The only problem in what you are suggesting is that you may end swapping
> out also the wrong pages. Suppose you want to allocate 4k of DMA
> memory.

I agree.

HOWEVER, I don't think this is going to be a huge issue in most cases. And
if people don't need non-DMA memory, then the pages we "swapped" out are
going to stay in RAM anyway, so it's not going to hurt us.

Anyway, I obviously do agree that I may well be wrong, and that real life
is going to come back and bite us, and we'll end up having to not do it
this way. However, I'd prefer trying the "conceptually simple" path first,
and only if it turns out that yes, I was completely wrong, do we try to
fix it up with magic heuristics etc.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
