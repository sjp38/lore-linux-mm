Date: Mon, 4 Feb 2008 09:55:26 -0800
From: mark gross <mgross@linux.intel.com>
Subject: Re: Pull request: DMA pool updates
Message-ID: <20080204175526.GA21144@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20080129001147.GD31101@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080129001147.GD31101@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2008 at 05:11:47PM -0700, Matthew Wilcox wrote:
> G'day Linus, mate
> 
> Could you pull the dmapool branch of
> git://git.kernel.org/pub/scm/linux/kernel/git/willy/misc.git please?
> 
> All the patches have been posted to linux-kernel before, and various
> comments (and acks) have been taken into account.
> 
> It's a fairly nice performance improvement, so would be good to get in.
> It's survived a few hours of *mumble* high-stress database benchmark,
> so I have high confidence in its stability.

I haven't looked at this yet but, I've been doing some work with the
IOMMU performance impacts on DMA operations.  DMApooling  could provide
a way to mitigate some of the spankage gotten when using IOMMU's.

--mgross

> 
> -- 
> Intel are signing my paycheques ... these opinions are still mine
> "Bill, look, we understand that you're interested in selling us this
> operating system, but compare it to ours.  We can't possibly take such
> a retrograde step."
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
