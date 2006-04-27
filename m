Date: Thu, 27 Apr 2006 10:03:16 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Lockless page cache test results
Message-ID: <20060427080316.GL9211@suse.de>
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426185750.GM5002@suse.de> <20060427111937.deeed668.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060427111937.deeed668.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 27 2006, KAMEZAWA Hiroyuki wrote:
> On Wed, 26 Apr 2006 20:57:50 +0200
> Jens Axboe <axboe@suse.de> wrote:
> 
> > On Wed, Apr 26 2006, Jens Axboe wrote:
> > > We can speedup the lookups with find_get_pages(). The test does 64k max,
> > > so with luck we should be able to pull 16 pages in at the time. I'll try
> > > and run such a test. But boy I wish find_get_pages_contig() was there
> > > for that. I think I'd prefer adding that instead of coding that logic in
> > > splice, it can get a little tricky.
> > 
> > Here's such a run, graphed with the other two. I'll redo the lockless
> > side as well now, it's only fair to compare with that batching as well.
> > 
> 
> Hi, thank you for interesting tests.
> 
> >From user's view, I want to see the comparison among 
> - splice(file,/dev/null),
> - mmap+madvise(file,WILLNEED)/write(/dev/null),
> - read(file)/write(/dev/null)
> in this 1-4 threads test. 
> 
> This will show when splice() can be used effectively.

Sure, should be easy enough to do.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
