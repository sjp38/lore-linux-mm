Date: Sat, 9 Jun 2001 08:07:06 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: Comment on patch to remove nr_async_pages limit
In-Reply-To: <Pine.LNX.4.21.0106090008110.10415-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.33.0106090758530.748-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 Jun 2001, Rik van Riel wrote:

> On 5 Jun 2001, Zlatko Calusic wrote:
> > Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> >
> > [snip]
> > > Exactly. And when we reach a low watermark of memory, we start writting
> > > out the anonymous memory.
> >
> > Hm, my observations are a little bit different. I find that writeouts
> > happen sooner than the moment we reach low watermark, and many times
> > just in time to interact badly with some read I/O workload that made a
> > virtual shortage of memory in the first place.
>
> I have a patch that tries to address this by not reordering
> the inactive list whenever we scan through it. I'll post it
> right now ...

Excellent.  I've done some of that (crude but effective) and have had
nice encouraging results.  If the dirty list is long enough, this
most definitely improves behavior under heavy load.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
