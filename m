Date: Tue, 26 Sep 2000 16:05:54 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000926160554.B13832@athlon.random>
References: <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com> <20000925190347.E27677@athlon.random> <20000925190657.N2615@redhat.com> <20000925213242.A30832@athlon.random> <20000925205457.Y2615@redhat.com> <qwwd7hriqxs.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <qwwd7hriqxs.fsf@sap.com>; from cr@sap.com on Tue, Sep 26, 2000 at 08:54:23AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 08:54:23AM +0200, Christoph Rohland wrote:
> "Stephen C. Tweedie" <sct@redhat.com> writes:
> 
> > Hi,
> > 
> > On Mon, Sep 25, 2000 at 09:32:42PM +0200, Andrea Arcangeli wrote:
> > 
> > > Having shrink_mmap that browse the mapped page cache is useless
> > > as having shrink_mmap browsing kernel memory and anonymous pages
> > > as it does in 2.2.x as far I can tell. It's an algorithm
> > > complexity problem and it will waste lots of CPU.
> > 
> > It's a compromise between CPU cost and Getting It Right.  Ignoring the
> > mmap is not a good solution either.
> > 
> > > Now think this simple real life example. A 2G RAM machine running
> > > an executable image of 1.5G, 300M in shm and 200M in cache.
> 
> Hey that's ridiculous: 1.5G executable image and 300M shm? Take it
> vice-versa and you are approaching real life.

Could you tell me what's wrong in having an app with a 1.5G mapped executable
(or a tiny executable but with a 1.5G shared/private file mapping if you
prefer), 300M of shm (or 300M of anonymous memory if you prefer) and 200M as
filesystem cache?

The application have a misc I/O load that in some part will run out
of the working set, what's wrong with this?

What's ridiculous? Please elaborate.

To emulate that workload we only need to mmap(1.5G, MAP_PRIVATE or MAP_SHARED),
fault into it, and run bonnie.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
