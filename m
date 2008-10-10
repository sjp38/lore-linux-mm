Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20081010133719.GC16353@mit.edu>
References: <20081009155039.139856823@suse.de>
	 <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org>
	 <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org>
	 <20081010133719.GC16353@mit.edu>
Content-Type: text/plain
Date: Fri, 10 Oct 2008 09:56:44 -0400
Message-Id: <1223647004.9997.20.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-10-10 at 09:37 -0400, Theodore Tso wrote:
> On Fri, Oct 10, 2008 at 09:13:25AM -0400, Christoph Hellwig wrote:
> > On Fri, Oct 10, 2008 at 09:10:30AM -0400, Theodore Tso wrote:
> > > > Aneesh has a patch to kill the range_cont flag, which is queued up for
> > > > 2.6.28.
> > > 
> > > Which tree is this queued up in?  It's not in ext4 or the mm tree...
> > 
> > Oh, it' not queued up yet?  It's part of the patch that switches ext4
> > to it's own copy of write_cache_pages to fix the buffer write issues.
> > 
> 
> I held off queing it up since the version Aneesh did created ext4's
> own copy of write_cache_pages, and given that Nick has a bunch of
> fixes and improvements for write_cache_pages, it confirmed my fears
> that queueing a patch which copied ~100 lines of code into ext4 was
> probably not the best way to go.
> 

What I was hoping for when I suggested copying it in was a larger move
of logic from the ext4 writepages code into the ext4 write_cache_pages.
The idea was to see what ext4 really needed write_cache_pages to do, but
Aneesh knows much better than I do there.

But, given that the change was only a few lines, I think it makes sense
to fold it back into write_cache_pages.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
