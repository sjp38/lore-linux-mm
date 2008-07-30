In-reply-to: <20080730194516.GO20055@kernel.dk> (message from Jens Axboe on
	Wed, 30 Jul 2008 21:45:16 +0200)
Subject: Re: [patch v3] splice: fix race with page invalidation
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807300958390.3334@nehalem.linux-foundation.org> <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu> <20080730175406.GN20055@kernel.dk> <E1KOGT8-0000rd-0Z@pomaz-ex.szeredi.hu> <E1KOGeO-0000yi-EM@pomaz-ex.szeredi.hu> <20080730194516.GO20055@kernel.dk>
Message-Id: <E1KOHvq-0001oX-OW@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 30 Jul 2008 22:05:58 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: miklos@szeredi.hu, torvalds@linux-foundation.org, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jul 2008, Jens Axboe wrote:
> On Wed, Jul 30 2008, Miklos Szeredi wrote:
> > > On Wed, 30 Jul 2008, Jens Axboe wrote:
> > > > You snipped the part where Linus objected to dismissing the async
> > > > nature, I fully agree with that part.
> > 
> > And also note in what Nick said in the referenced mail: it would be
> > nice if someone actually _cared_ about the async nature.  The fact
> > that it has been broken from the start, and nobody noticed is a strong
> > hint that currently there isn't anybody who does.
> 
> That's largely due to the (still) lack of direct splice users. It's a
> clear part of the design and benefit of using splice. I very much care
> about this, and as soon as there are available cycles for this, I'll get
> it into better shape in this respect. Taking a step backwards is not the
> right way forward, imho.

So what is?  The only way forward is to put those cycles into it,
which nobody seems to have available.

Take this patch as a bugfix.  It's not in any way showing the way
forward: as soon as you have the time, you can revert it and start
from the current state.

Hmm?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
