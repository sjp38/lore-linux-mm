Date: Tue, 5 Jun 2001 23:00:59 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: Comment on patch to remove nr_async_pages limitA
In-Reply-To: <Pine.LNX.3.96.1010605151500.25725C-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.33.0106052211490.2310-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Zlatko Calusic <zlatko.calusic@iskon.hr>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jun 2001, Benjamin C.R. LaHaise wrote:

> On Tue, 5 Jun 2001, Mike Galbraith wrote:
>
> > Yes.  If we start writing out sooner, we aren't stuck with pushing a
> > ton of IO all at once and can use prudent limits.  Not only because of
> > potential allocation problems, but because our situation is changing
> > rapidly so small corrections done often is more precise than whopping
> > big ones can be.
>
> Hold on there big boy, writing out sooner is not better.  What if the

(do definitely beat my thoughts up, please don't use condescending terms)

In some cases, it definitely is.  I can routinely improve throughput
by writing more.. that is a measurable and reproducable fact.  I know
also from measurement that it is not _always_ the right thing to do.

> memory shortage is because real data is being written out to disk?

(I would hope that we're doing our best to always be writing real data
to disk.  I also know that this isn't always the case.)

> Swapping early causes many more problems than swapping late as extraneous
> seeks to the swap partiton severely degrade performance.

That is not the case here at the spot in the performance curve I'm
looking at (transition to throughput).

Does this mean the block layer and/or elevator is having problems?  Why
would using avaliable disk bandwidth vs letting it lie dormant be a
generically bad thing?.. this I just can't understand.  The elevator
deals with seeks, the vm is flat not equipped to do so.. it contains
such concept.

Avoiding write is great, delaying write is not at _all_ great.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
