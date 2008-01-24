Date: Thu, 24 Jan 2008 00:03:36 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in sys_msync()
In-Reply-To: <alpine.LFD.1.00.0801231438530.2803@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0801232349170.9741@blonde.site>
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
 <1201044083504-git-send-email-salikhmetov@gmail.com>
 <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org>
 <1201110066.6341.65.camel@lappy> <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
 <E1JHlh8-0003s8-Bb@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231248060.2803@woody.linux-foundation.org>
 <E1JHmxa-0004BK-6X@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231329120.2803@woody.linux-foundation.org>
 <Pine.LNX.4.64.0801232216460.5465@blonde.site>
 <alpine.LFD.1.00.0801231438530.2803@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, a.p.zijlstra@chello.nl, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Linus Torvalds wrote:
> 
> So we certainly *could* make ramfs/tmpfs claim they do dirty accounting, 
> but just having a no-op writeback. Without that, they'd need something 
> really special in the file time updates.

What we might reasonably choose to end up doing there (in 2.6.25)
is sending tmpfs etc. through the extra faulting for linked files,
but skipping it as at present for unlinked files i.e. shared memory
would continue to skip the extra faults, shared memory being the case we
really wanted to avoid the overhead on when dirty page accounting came in.

> Personally, I don't really see anybody really caring one way or the other, 
> but who knows..

I care a bit, because I don't like to feel that tmpfs is now left
saddled with the bug that every filesystem has had for years before.
I'll need to compare the small performance cost of fixing it against
the unease of leaving it alone.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
