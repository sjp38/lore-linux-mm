Date: Tue, 23 May 2000 12:51:15 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [PATCH--] Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)
In-Reply-To: <392AA3D5.FD6B5399@norran.net>
Message-ID: <Pine.BSO.4.20.0005231244060.1176-100000@naughty.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

hi roger-

list manipulations are probably more expensive than maintaining a "load
average" value associated with a page.  usually a list manipulation will
require several memory writes into areas shared across CPUs; maintaining a
weighted load average requires a single write.

this was an issue with andrea's original LRU implementation, IIRC.

On Tue, 23 May 2000, Roger Larsson wrote:

> From: Matthew Dillon <dillon@apollo.backplane.com>
> >     The algorithm is a *modified* LRU.  Lets say you decide on a weighting
> >     betweeen 0 and 10.  When a page is first allocated (either to the
> >     buffer cache or for anonymous memory) its statistical weight is
> >     set to the middle (5).  If the page is used often the statistical 
> >     weight slowly rises to its maximum (10).  If the page remains idle
> >     (or was just used once) the statistical weight slowly drops to its
> >     minimum (0).
> 
> My patches has been approaching this a while... [slowly...]
> The currently included patch adds has divided lru in four lists [0..3].
> New pages are added at level 1.
> Scan is performed - and referenced pages are moved up.
> 
> Pages are moved down due to list balancing, but I have been playing with
> other ideas.
> 
> These patches should be a good continuation point.
> Patches are against pre9-3 with Quintela applied.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@bigfoot.com>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
