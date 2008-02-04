Date: Mon, 4 Feb 2008 14:39:39 -0500
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [patch 0/3] add perform_write to a_ops
Message-ID: <20080204193939.GA19236@lst.de>
References: <20080204170409.991123259@szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080204170409.991123259@szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2008 at 06:04:10PM +0100, Miklos Szeredi wrote:
> a_ops->perform_write() was left out from Nick Piggin's new a_ops
> patchset, as it was non-essential, and postponed for later inclusion.
> 
> This short series reintroduces it, but only adds the fuse
> implementation and not simple_perform_write(), which I'm not sure
> would be a significant improvement.
> 
> This allows larger than 4k buffered writes for fuse, which is one of
> the most requested features.
> 
> This goes on top of the "fuse: writable mmap" patches.

Please don't do this, but rather implement your own .aio_write.  There's
very little in generic_file_aio_write that wouldn't be handle by
->perform_write and we should rather factor those up or move to higher
layers than adding this ill-defined abstraction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
