Date: Mon, 9 Sep 2002 17:03:00 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified segq for 2.5
In-Reply-To: <3D7CFCCC.1A6A686A@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209091700380.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Sep 2002, Andrew Morton wrote:

> > OK, in that case there's no problem.  If the working set
> > really does take 90% of RAM that's a good thing to know ;)
>
> The working set appears to be 100.000% of RAM, hence the wild
> swings in throughput when you give or take half a meg.

In that case some form of load control should kick in,
when the working set no longer fits in RAM we should
degrade gracefully instead of just breaking down.

Implementing load control is not an excercise that
should be left to most readers, however ;)

> > > Generally, where do you want to go with this code?
> >
> > If this code turns out to be more predictable and better
> > or equal performance to use-once, I'd like to see it in
> > the kernel.  Use-once seems just too hard to tune right
> > for all workloads.
>
> gack.  How do we judge that, without waiting a month and
> measuring the complaint level?  (Here I go again).

Beats me. We have reasoning and trying the thing on our own
systems, but there don't seem to be any tools to measure
what you want to know...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
