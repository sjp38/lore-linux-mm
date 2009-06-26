Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E9CD46B004D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 07:35:35 -0400 (EDT)
From: Al Boldi <a1426z@gawab.com>
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
Date: Fri, 26 Jun 2009 14:37:16 +0300
References: <1245839904.3210.85.camel@localhost.localdomain> <200906252010.33535.a1426z@gawab.com> <20090626050245.GL31415@kernel.dk>
In-Reply-To: <20090626050245.GL31415@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200906261437.16995.a1426z@gawab.com>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
> On Thu, Jun 25 2009, Al Boldi wrote:
> > Jens Axboe wrote:
> > > The test case is random mmap writes to files that have been laid out
> > > sequentially. So it's all seeks. The target drive is an SSD disk
> > > though, so it doesn't matter a whole lot (it's a good SSD).
> >
> > Oh, SSD.  What numbers do you get for normal disks?
>
> I haven't run this particular test on rotating storage. The type of
> drive should not matter a lot, I'm mostly interested in comparing
> vanilla and the writeback patches on identical workloads and storage.

I think drive type matters a lot.  Access strategy on drives with high seek 
delays differs from those with no seek delays.  So it would probably be of 
interest to see this test run on rotating storage, unless the writeback 
patches are only meant for SSD?


Thanks!

--
Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
