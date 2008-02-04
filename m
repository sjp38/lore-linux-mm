In-reply-to: <20080204193939.GA19236@lst.de> (message from Christoph Hellwig
	on Mon, 4 Feb 2008 14:39:39 -0500)
Subject: Re: [patch 0/3] add perform_write to a_ops
References: <20080204170409.991123259@szeredi.hu> <20080204193939.GA19236@lst.de>
Message-Id: <E1JM8IQ-0003pP-Dw@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 04 Feb 2008 21:52:06 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hch@lst.de
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > a_ops->perform_write() was left out from Nick Piggin's new a_ops
> > patchset, as it was non-essential, and postponed for later inclusion.
> > 
> > This short series reintroduces it, but only adds the fuse
> > implementation and not simple_perform_write(), which I'm not sure
> > would be a significant improvement.
> > 
> > This allows larger than 4k buffered writes for fuse, which is one of
> > the most requested features.
> > 
> > This goes on top of the "fuse: writable mmap" patches.
> 
> Please don't do this, but rather implement your own .aio_write.  There's
> very little in generic_file_aio_write that wouldn't be handle by
> ->perform_write and we should rather factor those up or move to higher
> layers than adding this ill-defined abstraction.
> 

Moving up to higher layers might not be possible, due to lock/unlock
of i_mutex being inside generic_file_aio_write().

But with fuse being the only user, it's not a huge issue duplicating
some code.

Nick, were there any other candidates, that would want to use such an
interface in the future?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
