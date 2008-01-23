Date: Wed, 23 Jan 2008 22:29:49 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in sys_msync()
In-Reply-To: <alpine.LFD.1.00.0801231329120.2803@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0801232216460.5465@blonde.site>
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
 <1201044083504-git-send-email-salikhmetov@gmail.com>
 <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org>
 <1201110066.6341.65.camel@lappy> <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
 <E1JHlh8-0003s8-Bb@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231248060.2803@woody.linux-foundation.org>
 <E1JHmxa-0004BK-6X@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231329120.2803@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, a.p.zijlstra@chello.nl, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Linus Torvalds wrote:
> On Wed, 23 Jan 2008, Miklos Szeredi wrote:
> 
> > Sure, I would have though all of this stuff is 2.6.25, but it's your
> > kernel... :)
> 
> Well, the plain added "file_update_time()" call addition looked like a 
> trivial fix, and if there are actually *customers* that have bad backups 
> due to this, then I think that part was worth doing. At least a "sync" 
> will then sync the file times...

Fair enough.

Something I dislike about it, though, is that it leaves the RAM-backed
filesystems (ramfs, tmpfs, whatever) behaving visibly differently from
the others.  Until now we've intentionally left them out of syncing and
dirty accounting, because it's useless overhead for them (one can argue
whether that's quite true of tmpfs overflowing out to swap, but that's
a different debate).  So they won't be getting these faults on shared
writable, so their file times won't get updated in the same way.

But I guess that's an aesthetic consideration, of less significance
than bad backups - assuming not many people use backups of tmpfs.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
