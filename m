Date: Thu, 15 Mar 2007 16:59:12 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/2] shmem: fix BUG in shmem_writepage
Message-ID: <20070315235912.GG8915@holomorphy.com>
References: <E1HRaWY-0001mn-00@dorka.pomaz.szeredi.hu> <Pine.LNX.4.64.0703151909410.7795@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703151909410.7795@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de, badari@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 07:35:06PM +0000, Hugh Dickins wrote:
> And congratulations on working out how to go about fixing it:
> shmem_truncate was very much more comprehensible before I converted it
> to kmap'ing highmem index pages.  I had very mixed feelings over the
> result of that conversion, but it worked until punch_hole came along.
> Yes, there's a bug in the freeing that I never noticed,
> and yes there are races to which I turned a blind eye.
> I cannot give you an ACK on these patches immediately, any more than
> I could ACK the original buggy patch: I'll have to think through it
> all myself in the next few days.  I hope it can be done a little
> differently than with punch_hole tests all over.
> But I'm happy for your patches to go into -mm for now - thanks.

I suppose I'm partly responsible, so I'll put another pair of eyes on
it, not that I expect to be able to come up with any meaningful
commentary, much less spot bugs.


On Thu, Mar 15, 2007 at 07:35:06PM +0000, Hugh Dickins wrote:
> (What I'd love is to throw away _all_ that shmem index code, and
> use the pagecache's radixtree to store swapentries in place of
> pagepointers when swapped out.  But that has the disadvantage
> that the memory used can never be highmem - unless we code up
> highmem radixtrees, which would be a very misdirected effort.
> Plus I think I saw Andrew contemplating some other use for the
> empty radixtree entries just a few days ago.  Anyway, the bugs
> need to be fixed before any such rewrite.)

I'm the last kernel hacker in existence who actually likes the
idea of working well on highmem, so the usual grain of salt applies,
but I rather like the highmem-allocated indirect blocks. Maybe it's
nothing but nostalgia at this point. My only regret is not having
written it myself.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
