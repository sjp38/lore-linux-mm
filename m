Date: Sat, 15 Jan 2005 00:01:18 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
Message-ID: <20050114230118.GP8709@dualathlon.random>
References: <20050114213207.GK8709@dualathlon.random> <Pine.LNX.4.44.0501142217590.3109-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0501142217590.3109-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Kanoj Sarcar <kanojsarcar@yahoo.com>, Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, davem@redhat.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 14, 2005 at 10:36:17PM +0000, Hugh Dickins wrote:
> On Fri, 14 Jan 2005, Andrea Arcangeli wrote:
> > > 
> > > You could have asked even before breaking mainline ;).
> 
> Sorry (but check your mailbox for 3rd October -
> I'd hoped the patch would be more provocative than a question!)

Hmm I thought it was more recent, so I guess it could have been when I
got the @novell.com email downtime. I lost email for several days, then
I got back to @suse.de. Sorry anyway!

> I don't follow your argument for atomic there - "just in case"?
> I still see its atomic ops as serving no point (and it was
> tiresome to extend their use in the patches that followed).

Actually see the last email I posted, seems like we need both a
smp_wmb() before the increase and a smp_mb() after it. The reason is
that it must be done in that very order. And on x86 doing it with
atomic_inc would enforce it.

I definitely agree truncate_count can be done in C _after_ we add
smp_wmb() before the increase and smp_mb() after the increase.

Infact now that I think about this will also avoid us to implement
smp_wmb__before_atomic_add.

> That's interesting, and I'm glad my screwup has borne some good fruit.

Indeed ;). Me too.

> And an smp_rmb() in one place makes more sense to me if there's an
> smp_wmb() in the complementary place (though I've a suspicion that

Hmm, I assume you meant "there's _not_ an", otherwise I don't get it.

> Will do, though not today.

Thanks! The only problem here is ia64, few people runs test kernels in
production so it's not an hurry.

I also need to rediff my pending VM stuff for Andrew but I've been
extremely busy with other kernel stuff in the last few days, so I had no
time for that yet.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
