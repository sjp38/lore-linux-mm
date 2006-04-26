Date: Wed, 26 Apr 2006 21:46:23 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Lockless page cache test results
Message-ID: <20060426194623.GD9211@suse.de>
References: <20060426135310.GB5083@suse.de> <444F8714.9060808@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <444F8714.9060808@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 27 2006, Nick Piggin wrote:
> Jens Axboe wrote:
> >Hi,
> >
> >Running a splice benchmark on a 4-way IPF box, I decided to give the
> >lockless page cache patches from Nick a spin. I've attached the results
> >as a png, it pretty much speaks for itself.
> >
> >The test in question splices a 1GiB file to a pipe and then splices that
> >to some output. Normally that output would be something interesting, in
> >this case it's simply /dev/null. So it tests the input side of things
> >only, which is what I wanted to do here. To get adequate runtime, the
> >operation is repeated a number of times (120 in this example). The
> >benchmark does that number of loops with 1, 2, 3, and 4 clients each
> >pinned to a private CPU. The pinning is mainly done for more stable
> >results.
> 
> Thanks Jens!
> 
> It's interesting, single threaded performance is down a little. Is
> this significant? In some other results you showed me with 3 splices
> each running on their own file (ie. no tree_lock contention), lockless
> looked slightly faster on the same machine.

I can't say for sure, as I haven't done enough of these runs to know for
a fact if it's just a little fluctuation or actually statistically
significant. The tests are quick to run, I'll do a series of single
thread runs tomorrow to tell you.

> It could well be that the speculative get_page operation is naturally
> a bit slower on Itanium CPUs -- there is a different mix of barriers,
> reads, writes, etc. If only someone gave me an IPF system... ;)

I'll gladly trade the heat and noise generation of that beast with you
:-)

I can do the same numbers on a 2-way em64t for comparison, that should
get us a little better coverage.

> As you said, it would be nice to see how this goes when the other end
> are 4 gigabit pipes or so... And then things like specweb and file
> serving workloads.

Yes, for now I just consider the /dev/null splicing an extremely fast
and extremely light weigth interconnect :-)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
