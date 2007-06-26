Date: Mon, 25 Jun 2007 21:23:20 -0600
From: Andreas Dilger <adilger@clusterfs.com>
Subject: Re: vm/fs meetup in september?
Message-ID: <20070626032320.GN5181@schatzie.adilger.int>
References: <20070624042345.GB20033@wotan.suse.de> <20070625063545.GA1964@infradead.org> <46807B5D.6090604@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46807B5D.6090604@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Jun 26, 2007  12:35 +1000, Nick Piggin wrote:
> Leaving my opinion of higher order pagecache aside, this _may_ be an
> example of something that doesn't need a lot of attention, because it
> should be fairly uncontroversial from a filesystem's POV? (eg. it is
> more a relevant item to memory management and possibly block layer).
> OTOH if it is discussed in the context of "large blocks in the buffer
> layer is crap because we can do it with higher order pagecache", then
> that might be interesting :)

FWIW, being able to have large (8-64kB) blocksize would be great for
ext2/3/4.  We'd sort of been betting on this by limiting the on-disk
extent format to 48-bit physical block numbers, and to have 2 patches
to implement this in as many weeks is excellent.

To me the mechanism doesn't matter, whether through fsblock or high-order
PAGE_SIZE.  I'll let the rest of you duke it out as long as at least one
of them makes it into the kernel.

Cheers, Andreas
--
Andreas Dilger
Principal Software Engineer
Cluster File Systems, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
