Date: Thu, 9 Dec 1999 18:09:24 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <Pine.LNX.4.10.9912100015520.10946-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.LNX.3.96.991209180518.21542B-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Rik van Riel <riel@nl.linux.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 1999, Ingo Molnar wrote:

> On Thu, 9 Dec 1999, Rik van Riel wrote:
> 
> > a "real" zoned allocator. Not a 2.4 thing,
> 
> would you mind elaborating what such a "real" zoned allocator has,
> compared to the current one?

The type of allocation determines what pool memory is allocated from.  Ie
nonpagable kernel allocations come from one zone, atomic allocations from
another and user from yet another.  It's basically the same thing that the
slab does, except for pages.  The key advantage is that allocations of
different types are not mixed, so the lifetime of allocations in the same
zone tends to be similar and fragmentation tends to be lower.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
