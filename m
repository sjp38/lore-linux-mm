Date: Sun, 29 Jul 2001 23:19:20 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Message-ID: <20010729231920.A10320@thunk.org>
References: <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva>, <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva> <01072822131300.00315@starship> <3B6369DE.F9085405@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B6369DE.F9085405@zip.com.au>; from akpm@zip.com.au on Sun, Jul 29, 2001 at 11:41:50AM +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 29, 2001 at 11:41:50AM +1000, Andrew Morton wrote:
> 
> Be very wary of optimising for dbench.
> 
> It's a good stress tester, but I don't think it's a good indicator of how
> well an fs or the VM is performing.  It does much more writing than a
> normal workload mix.  It generates oceans of metadata.

People should keep in mind what dbench was originally written to do
--- to be a easy-to-run proxy for the netbench benchmark, so that
developers could have a relatively easy way to determine how
well/poorly their systems would run on netbench run without having to
set up an expensive and hard-to-maintain cluster of Windows clients in
order to do a full-blown netbench benchmark.

Most people agree that netbench is a horrible benchmark, but the
reality is that it's what a lot of the world (including folks like
Mindcraft) use it for benchmarking SMB/CIFS servers.  So while we
shouldn't optimize dbench/netbench numbers at the expense of
real-world performance, we can be sure that Microsoft will be doing so
(and will no doubt call in Mindcraft or some other "independent
benchmarking/testing company" to be their shill once they've finished
with their benchmark hacking. :-)

> It would be very useful to have a standardised and very carefully
> chosen set of tests which we could use for evaluating fs and kernel
> performance.  I'm not aware of anything suitable, really.  It would
> have to be a whole bunch of datapoints sprinkled throughout a
> multidimesional space.  That's what we do at present, but it's ad-hoc.

All the gripes about dbench/netbench aside, one good thing about them
is that they hit the filesystem with a large number of operations in
parallel, which is what a fileserver under heavy load will see.
Benchmarks like Andrew and Bonnie tend to have a much more serialized
pattern of filesystem access.

						- Ted
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
