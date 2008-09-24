Date: Wed, 24 Sep 2008 21:00:43 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] hugetlbfs: add llseek method
Message-ID: <20080924190043.GA2312@lst.de>
References: <20080908174634.GC19912@lst.de> <20080922185624.GA26551@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080922185624.GA26551@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@lst.de>, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 22, 2008 at 07:56:25PM +0100, Mel Gorman wrote:
> On (08/09/08 19:46), Christoph Hellwig didst pronounce:
> > Hugetlbfs currently doesn't set a llseek method for regular files, which
> > means it will fall back to default_llseek.  This means no one can seek
> > beyond 2 Gigabytes.
> > 
> 
> I took another look at this as it was pointed out to me by apw that this
> might be a SEEK_CUR vs SEEK_SET thing and also whether lseek() was the
> key. To use lseek though, the large file defines had to be used or it failed
> whether your patch was applied or not. The error as you'd expect is lseek()
> complaining that the type was too small.
> 
> At the face of it, the patch seems sensible but it works whether it is set
> or not so clearly I'm still missing something. The second test I tried is
> below. In the unlikely event it makes a difference, I was testing on qemu
> for i386.

Sorry, my original description was complete bullsh*t ;-)  The problem
is the inverse of what I wrote.  With default_llseek you can seek
everywhere even if that's outside of the fs limit.  This should give you
quite interesting results if you seek outside of what we can represent
page->index on 32bit platforms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
