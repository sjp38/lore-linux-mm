Date: Wed, 30 Jul 2008 21:45:16 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [patch v3] splice: fix race with page invalidation
Message-ID: <20080730194516.GO20055@kernel.dk>
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807300958390.3334@nehalem.linux-foundation.org> <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu> <20080730175406.GN20055@kernel.dk> <E1KOGT8-0000rd-0Z@pomaz-ex.szeredi.hu> <E1KOGeO-0000yi-EM@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KOGeO-0000yi-EM@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 30 2008, Miklos Szeredi wrote:
> > On Wed, 30 Jul 2008, Jens Axboe wrote:
> > > You snipped the part where Linus objected to dismissing the async
> > > nature, I fully agree with that part.
> 
> And also note in what Nick said in the referenced mail: it would be
> nice if someone actually _cared_ about the async nature.  The fact
> that it has been broken from the start, and nobody noticed is a strong
> hint that currently there isn't anybody who does.

That's largely due to the (still) lack of direct splice users. It's a
clear part of the design and benefit of using splice. I very much care
about this, and as soon as there are available cycles for this, I'll get
it into better shape in this respect. Taking a step backwards is not the
right way forward, imho.

> Maybe fuse will be the first one to actually care, and then I'll
> bother with putting a lot of effort into it.  But until someone cares,
> nobody will bother, and that's how it should be.  That's very much in
> line with the evoultionary nature of kernel developments: unused
> features will just get broken and eventually removed.

People always say then, and the end result is it never gets done. Not to
point the finger at Nick, but removing the steal part of the splice
design was something I objected to a lot. Yet it was acked on the
premise that it would eventually get resubmitted in a fixed manner, but
were are not further along that path.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
