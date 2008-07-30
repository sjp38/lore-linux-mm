In-reply-to: <E1KOGT8-0000rd-0Z@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Wed, 30 Jul 2008 20:32:14 +0200)
Subject: Re: [patch v3] splice: fix race with page invalidation
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807300958390.3334@nehalem.linux-foundation.org> <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu> <20080730175406.GN20055@kernel.dk> <E1KOGT8-0000rd-0Z@pomaz-ex.szeredi.hu>
Message-Id: <E1KOGeO-0000yi-EM@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 30 Jul 2008 20:43:52 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: miklos@szeredi.hu, torvalds@linux-foundation.org, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 30 Jul 2008, Jens Axboe wrote:
> > You snipped the part where Linus objected to dismissing the async
> > nature, I fully agree with that part.

And also note in what Nick said in the referenced mail: it would be
nice if someone actually _cared_ about the async nature.  The fact
that it has been broken from the start, and nobody noticed is a strong
hint that currently there isn't anybody who does.

Maybe fuse will be the first one to actually care, and then I'll
bother with putting a lot of effort into it.  But until someone cares,
nobody will bother, and that's how it should be.  That's very much in
line with the evoultionary nature of kernel developments: unused
features will just get broken and eventually removed.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
