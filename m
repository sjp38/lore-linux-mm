Date: Wed, 23 Jan 2008 14:41:53 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in
 sys_msync()
In-Reply-To: <Pine.LNX.4.64.0801232216460.5465@blonde.site>
Message-ID: <alpine.LFD.1.00.0801231438530.2803@woody.linux-foundation.org>
References: <12010440803930-git-send-email-salikhmetov@gmail.com>  <1201044083504-git-send-email-salikhmetov@gmail.com>  <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org> <1201110066.6341.65.camel@lappy> <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
 <E1JHlh8-0003s8-Bb@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231248060.2803@woody.linux-foundation.org> <E1JHmxa-0004BK-6X@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231329120.2803@woody.linux-foundation.org> <Pine.LNX.4.64.0801232216460.5465@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, a.p.zijlstra@chello.nl, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>


On Wed, 23 Jan 2008, Hugh Dickins wrote:
> 
> Something I dislike about it, though, is that it leaves the RAM-backed
> filesystems (ramfs, tmpfs, whatever) behaving visibly differently from
> the others.

I hear you. 

But I'm not seeing many alternatives, unless we start taking write faults 
on them unnecessarily. Do we care? Probably not really. 

So we certainly *could* make ramfs/tmpfs claim they do dirty accounting, 
but just having a no-op writeback. Without that, they'd need something 
really special in the file time updates.

Personally, I don't really see anybody really caring one way or the other, 
but who knows..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
