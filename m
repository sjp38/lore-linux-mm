Date: Wed, 26 Apr 2000 09:52:56 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.21.0004261420340.624-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10004260949400.1492-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 26 Apr 2000, Andrea Arcangeli wrote:
> 
> NUMA is irrelevant. If there's no inclusion the classzone matches with the
> zone.

But then all your arguments evaporate.

If you argue that memory balancing should work even in the instance where
the classzone has degenerated into a single zone, then I'll just say "why
have the classzone concept at all, then?".

Which is exactly what I'm saying.

I think we should have zones. Not classzones. And we should have
"zonelists", but those would not be first-class data structures, they'd
just be lists of zones that are acceptable for an allocation.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
