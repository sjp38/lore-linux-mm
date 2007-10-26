Date: Fri, 26 Oct 2007 19:44:09 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20071026174409.GA1573@elf.ucw.cz>
References: <Pine.LNX.4.64.0709101220001.24735@schroedinger.engr.sgi.com> <1189454145.21778.48.camel@twins> <Pine.LNX.4.64.0709101318160.25407@schroedinger.engr.sgi.com> <1189457286.21778.68.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1189457286.21778.68.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi!

> > > or
> > > 
> > >   - have a global reserve and selectively serves sockets
> > >     (what I've been doing)
> > 
> > That is a scalability problem on large systems! Global means global 
> > serialization, cacheline bouncing and possibly livelocks. If we get into 
> > this global shortage then all cpus may end up taking the same locks 
> > cycling thought the same allocation paths.
> 
> Dude, breathe, these boxens of yours will never swap over network simply
> because you never configure swap. 
> 
> And, _no_, it does not necessarily mean global serialisation. By simply
> saying there must be N pages available I say nothing about on which node
> they should be available, and the way the watermarks work they will be
> evenly distributed over the appropriate zones.

Agreed. Scalability of emergency swapping reserved is simply
unimportant. Please, lets get swapping to _work_ first, then we can
make it faster.

No, I do not think we'll ever see a livelock on this.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
