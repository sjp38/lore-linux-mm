In-reply-to: <1195156900.22457.32.camel@lappy> (message from Peter Zijlstra on
	Thu, 15 Nov 2007 21:01:39 +0100)
Subject: Re: [RFC] fuse writable mmap design
References: <E1IshIR-0000fE-00@dorka.pomaz.szeredi.hu>
	 <1195154530.22457.16.camel@lappy>
	 <E1IskWl-0000oJ-00@dorka.pomaz.szeredi.hu>
	 <1195155759.22457.29.camel@lappy>
	 <E1Iskpw-0000qY-00@dorka.pomaz.szeredi.hu> <1195156900.22457.32.camel@lappy>
Message-Id: <E1Isl3p-0000rl-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 15 Nov 2007 21:11:37 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > OTOH, I'm thinking about adding a per-fs limit (adjustable for
> > privileged mounts) of dirty+writeback.
> > 
> > I'm not sure how hard would it be to add support for this into
> > balance_dirty_pages().  So I'm thinking of a parameter in struct
> > backing_dev_info that is used to clip the calculated per-bdi threshold
> > below this maximum.
> > 
> > How would that affect the proportions algorithm?  What would happen to
> > the unused portion?  Would it adapt to the slowed writeback and
> > allocate it to some other writer?
> 
> The unused part is gone, I've not yet found a way to re-distribute this
> fairly.
> 
> [ It's one of my open-problems, I can do a min_ratio per bdi, but not
>   yet a max_ratio ]

OK, I'll bear this in mind.

Limiting the number of dirty+writeback to << dirty_thresh could still
make sense, since it could prevent a nasty filesystem from pinning
lots of kernel memory (which it can do without fuse in other ways, so
this is not very important IMO).

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
