Message-ID: <3D3B9A6F.12B096E1@zip.com.au>
Date: Sun, 21 Jul 2002 22:38:55 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][1/2] return values shrink_dcache_memory etc
References: <Pine.LNX.4.44L.0207201740580.12241-100000@imladris.surriel.com> <Pine.LNX.4.44.0207201351160.1552-100000@home.transmeta.com> <3D3B925D.624986EE@zip.com.au> <20020722051608.GB919@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Sun, Jul 21, 2002 at 10:04:29PM -0700, Andrew Morton wrote:
> > I'd suggest that we avoid putting any additional changes into
> > the VM until we have solutions available for:
> > 2: Make it work with pte-highmem  (Bill Irwin is signed up for this)
> > 4: Move the pte_chains into highmem too (Bill, I guess)
> > 6: maybe GC the pte_chain backing pages. (Seems unavoidable.  Rik?)
> > Especially pte_chains in highmem.  Failure to fix this well
> > is a showstopper for rmap on large ia32 machines, which makes
> > it a showstopper full stop.
> 
> I'll send you an update of my solution for (6), the initial version of
> which was posted earlier today, in a separate post.

Thanks, Bill.  Yup, I'm playing with pte_chain_mempool at present.

> highpte_chain will do (2) and (4) simultaneously when it's debugged.
> 
> On Sun, Jul 21, 2002 at 10:04:29PM -0700, Andrew Morton wrote:
> > If we can get something in place which works acceptably on Martin
> > Bligh's machines, and we can see that the gains of rmap (whatever
> > they are ;)) are worth the as-yet uncoded pains then let's move on.
> > But until then, adding new stuff to the VM just makes a `patch -R'
> > harder to do.
> 
> I have the same kinds of machines and have already been testing with
> precisely the many tasks workloads he's concerned about for the sake of
> correctness, and efficiency is also a concern here. highpte_chain is
> already so high up on my priority queue that all other work is halted.

OK.  But we're adding non-trivial amounts of new code simply
to get the reverse mapping working as robustly as the virtual
scan.  And we'll always have rmap's additional storage requirements.

At some point we need to make a decision as to whether it's all
worth it.  Right now we do not even have the information on the
pluses side to do this.  That's worrisome.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
