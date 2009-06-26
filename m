Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ABA236B005C
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:34:31 -0400 (EDT)
Date: Fri, 26 Jun 2009 14:35:33 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
Message-ID: <20090626123533.GM23611@kernel.dk>
References: <1245839904.3210.85.camel@localhost.localdomain> <200906252010.33535.a1426z@gawab.com> <20090626050245.GL31415@kernel.dk> <200906261437.16995.a1426z@gawab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200906261437.16995.a1426z@gawab.com>
Sender: owner-linux-mm@kvack.org
To: Al Boldi <a1426z@gawab.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 26 2009, Al Boldi wrote:
> Jens Axboe wrote:
> > On Thu, Jun 25 2009, Al Boldi wrote:
> > > Jens Axboe wrote:
> > > > The test case is random mmap writes to files that have been laid out
> > > > sequentially. So it's all seeks. The target drive is an SSD disk
> > > > though, so it doesn't matter a whole lot (it's a good SSD).
> > >
> > > Oh, SSD.  What numbers do you get for normal disks?
> >
> > I haven't run this particular test on rotating storage. The type of
> > drive should not matter a lot, I'm mostly interested in comparing
> > vanilla and the writeback patches on identical workloads and storage.
> 
> I think drive type matters a lot.  Access strategy on drives with high seek 
> delays differs from those with no seek delays.  So it would probably be of 
> interest to see this test run on rotating storage, unless the writeback 
> patches are only meant for SSD?

Don't get me wrong, I've tested a lot on rotating drives too. The
changelog for one of the patches even mentions results and vmstat for a
10 disk setup, all rotating disks.

What I'm saying is that this particular test is tailored for SSD's and
writeback. The patchset is not for SSD's in particular, it applies
equally across the board (even for non-block IO, like NFS).

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
