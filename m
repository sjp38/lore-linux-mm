Date: Fri, 10 Oct 2008 09:37:19 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
Message-ID: <20081010133719.GC16353@mit.edu>
References: <20081009155039.139856823@suse.de> <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org> <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081010131325.GA16246@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 09:13:25AM -0400, Christoph Hellwig wrote:
> On Fri, Oct 10, 2008 at 09:10:30AM -0400, Theodore Tso wrote:
> > > Aneesh has a patch to kill the range_cont flag, which is queued up for
> > > 2.6.28.
> > 
> > Which tree is this queued up in?  It's not in ext4 or the mm tree...
> 
> Oh, it' not queued up yet?  It's part of the patch that switches ext4
> to it's own copy of write_cache_pages to fix the buffer write issues.
> 

I held off queing it up since the version Aneesh did created ext4's
own copy of write_cache_pages, and given that Nick has a bunch of
fixes and improvements for write_cache_pages, it confirmed my fears
that queueing a patch which copied ~100 lines of code into ext4 was
probably not the best way to go.

That being said, I would dearly love to see the 10x improvement in
streaming write speed for ext4 make the 2.6.28 merge window, since
people will start benchmarking ext4 much more seriously in the near
future.  So, I was tempted to queue Aneesh's original version of the
fix --- but if we're going to get a version of the change which gets
the required changes into to the generic write_cache_pages(), I'm not
sure we have the time to coordinate ext4's and other filesystems'
needs into Nick's RFC patchset.

It wouldn't be hard to create a version of Aneesh's patch which makes
the change to the original write_cache_pages(), instead of creating
our own copy of ext4_write_cache_pages(), but it hasn't been done yet,
so it hasn't been queued.  We can probably do *that* pretty quickly,
and send it out for review, but it would almost certainly conflict
with Nick's patchset --- and I had assumed that Nick might be
interested in pushing this during this merge window given his concern
about data integrity correctness issues.   

So I think the main issue here is coordinating planned changes to core
code....

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
