Subject: Re: 2.4.8-pre1 and dbench -20% throughput
References: <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva>
	<Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva>
	<01072822131300.00315@starship> <3B6369DE.F9085405@zip.com.au>
	<20010729231920.A10320@thunk.org> <3B657A6E.2487127F@osdlab.org>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 30 Jul 2001 21:39:22 +0200
In-Reply-To: <3B657A6E.2487127F@osdlab.org> ("Randy.Dunlap"'s message of "Mon, 30 Jul 2001 08:17:02 -0700")
Message-ID: <87lml69pg5.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdlab.org>
Cc: Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@zip.com.au>, Daniel Phillips <phillips@bonn-fries.net>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

"Randy.Dunlap" <rddunlap@osdlab.org> writes:

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
> 

http://linux.inet.hr/
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
