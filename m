Date: Mon, 30 Jul 2001 19:52:12 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <3B657A6E.2487127F@osdlab.org>
Message-ID: <Pine.LNX.4.33.0107301935570.605-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdlab.org>
Cc: Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@zip.com.au>, Daniel Phillips <phillips@bonn-fries.net>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2001, Randy.Dunlap wrote:

> Theodore Tso wrote:
> >
> > On Sun, Jul 29, 2001 at 11:41:50AM +1000, Andrew Morton wrote:
> >
> > > It would be very useful to have a standardised and very carefully
> > > chosen set of tests which we could use for evaluating fs and kernel
> > > performance.  I'm not aware of anything suitable, really.  It would
> > > have to be a whole bunch of datapoints sprinkled throughout a
> > > multidimesional space.  That's what we do at present, but it's ad-hoc.
> >
> > All the gripes about dbench/netbench aside, one good thing about them
> > is that they hit the filesystem with a large number of operations in
> > parallel, which is what a fileserver under heavy load will see.
> > Benchmarks like Andrew and Bonnie tend to have a much more serialized
> > pattern of filesystem access.
>
> Is iozone (using threads) any better at this?
> We are currently using iozone.
>
> And where can I find Zlatko's xmm program that Mike mentioned?

I lost the original URL, but have the source if you want it.  It's
a simple histogram, with zero stats.  You can't do detailed analysis,
but if you only need to see the big picture, it's useful.

If you search the archives, you'll find the URL.  (or ask Zlatko)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
