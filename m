Date: Wed, 30 Jul 2008 19:54:07 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [patch v3] splice: fix race with page invalidation
Message-ID: <20080730175406.GN20055@kernel.dk>
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807300958390.3334@nehalem.linux-foundation.org> <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 30 2008, Miklos Szeredi wrote:
> On Wed, 30 Jul 2008, Linus Torvalds wrote:
> > On Wed, 30 Jul 2008, Miklos Szeredi wrote:
> > > 
> > > There are no real disadvantages: splice() from a file was
> > > originally meant to be asynchronous, but in reality it only did
> > > that for non-readahead pages, which happen rarely.
> > 
> > I still don't like this. I still don't see the point, and I still
> > think there is something fundamentally wrong elsewhere.

You snipped the part where Linus objected to dismissing the async
nature, I fully agree with that part.

> We discussed the possible solutions with Nick, and came to the
> conclusion, that short term (i.e. 2.6.27) this is probably the best
> solution.

Ehm where? Nick also said that he didn't like removing the ->confirm()
bits as they are completely related to the async nature of splice. You
already submitted this exact patch earlier and it was nak'ed.

> Long term sure, I have no problem with implementing async splice.
> 
> In fact, I may even have personal interest in looking at splice,
> because people are asking for a zero-copy interface for fuse.
> 
> But that is definitely not 2.6.27, so I think you should reconsider
> taking this patch, which is obviously correct due to its simplicity,
> and won't cause any performance regressions either.

Then please just fix the issue, instead of removing the bits that make
this possible.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
