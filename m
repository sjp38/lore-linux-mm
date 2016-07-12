Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A89536B025F
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 22:52:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so6536265pfa.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 19:52:05 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id f5si3600027pfk.77.2016.07.11.19.52.03
        for <linux-mm@kvack.org>;
        Mon, 11 Jul 2016 19:52:04 -0700 (PDT)
Date: Tue, 12 Jul 2016 12:52:01 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160712025201.GH1922@dastard>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
 <20160707232713.GM27480@dastard>
 <20160708095203.GB11498@techsingularity.net>
 <20160711004757.GN12670@dastard>
 <20160711090224.GB9806@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160711090224.GB9806@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 11, 2016 at 10:02:24AM +0100, Mel Gorman wrote:
> On Mon, Jul 11, 2016 at 10:47:57AM +1000, Dave Chinner wrote:
> > > I had tested XFS with earlier releases and noticed no major problems
> > > so later releases tested only one filesystem.  Given the changes since,
> > > a retest is desirable. I've posted the current version of the series but
> > > I'll queue the tests to run over the weekend. They are quite time consuming
> > > to run unfortunately.
> > 
> > Understood. I'm not following the patchset all that closely, so I
> > didn' know you'd already tested XFS.
> > 
> 
> It was needed anyway. Not all of them completed over the weekend. In
> particular, the NUMA machine is taking its time because many of the
> workloads are scaled by memory size and it takes longer.
> 
> > > On the fsmark configuration, I configured the test to use 4K files
> > > instead of 0-sized files that normally would be used to stress inode
> > > creation/deletion. This is to have a mix of page cache and slab
> > > allocations. Shout if this does not suit your expectations.
> > 
> > Sounds fine. I usually limit that test to 10 million inodes - that's
> > my "10-4" test.
> > 
> 
> Thanks.
> 
> 
> I'm not going to go through most of the results in detail. The raw data
> is verbose and not necessarily useful in most cases.

Yup, numbers look pretty good and all my concerns have gone away.
Thanks for testing, Mel! :P

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
