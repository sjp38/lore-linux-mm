Date: Tue, 26 Sep 2000 01:00:32 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000926010032.F5010@athlon.random>
References: <20000925213242.A30832@athlon.random> <Pine.LNX.4.21.0009251622500.4997-100000@duckman.distro.conectiva> <20000926002812.C5010@athlon.random> <yttaecwksu3.fsf@serpe.mitica>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <yttaecwksu3.fsf@serpe.mitica>; from quintela@fi.udc.es on Tue, Sep 26, 2000 at 12:30:28AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 12:30:28AM +0200, Juan J. Quintela wrote:
> Which is completely wrong if the program uses _any not completely_
> unusual locality of reference.  Think twice about that, it is more
> probable that you need more that 300MB of filesystem cache that you
> have an aplication that references _randomly_ 1.5GB of data.  You need
> to balance that _always_ :((((((

The application doesn't references ramdonly 1.5GB of data. Assume
there's a big executable large 2G (and yes I know there are) and I run it.
After some hour its RSS it's 1.5G. Ok?

So now this program also shmget a 300 Mbyte shm segment.

Now this program starts reading and writing terabyte of data that
wouldn't fit in cache even if there would be 300G of ram (and
this is possible too). Or maybe the program itself uses rawio
but then you at a certain point use the machine to run a tar somewhere.

Now tell me why this program needs more than 200Mbyte of fs cache
if the kernel doesn't waste time on the mapped pages (as in
classzone).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
