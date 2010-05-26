Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 982C36B01DE
	for <linux-mm@kvack.org>; Wed, 26 May 2010 09:45:01 -0400 (EDT)
Date: Wed, 26 May 2010 15:44:57 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526134457.GQ23411@kernel.dk>
References: <20100526111326.GA28541@lst.de> <20100526112125.GJ23411@kernel.dk> <20100526114018.GA30107@lst.de> <20100526114950.GK23411@kernel.dk> <20100526120855.GA30912@lst.de> <20100526122126.GL23411@kernel.dk> <20100526124549.GA32550@lst.de> <20100526125614.GM23411@kernel.dk> <20100526134208.GA2557@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526134208.GA2557@lst.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26 2010, Christoph Hellwig wrote:
> On Wed, May 26, 2010 at 02:56:15PM +0200, Jens Axboe wrote:
> > On Wed, May 26 2010, Christoph Hellwig wrote:
> > > On Wed, May 26, 2010 at 02:21:26PM +0200, Jens Axboe wrote:
> > > > Ugh ok I see it, I had the caller_frees reverted. Try this :-)
> > > 
> > > This seems to fix it.  Running some more tests now.
> > 
> > Goodie, then the analysis at least is correct. A potentially cleaner fix
> > would be to just allocate the WB_SYNC_NONE && sb_pinned work struct on
> > the stack, since then we can get rid of that nastiness in
> > wb_work_complete() as well (and not pass 'sb_pinned' around so much).
> > 
> > If you have time, care to test this one as well?
> 
> Both this and the previous one hang hard in xfstests 007, with no chance
> of getting a backtrace.
> 
> For now I would recommend to revert
> 21c12849fef73efc9a898b6702fe421fd774f515 and
> 29c795f02e68ecd7bb1374844d3e55e882ac158f,
> which makes xfstests run fine for me.

OK, thanks for the testing. I'll revert the two and work up a real
solution once I have the test equipment online again.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
