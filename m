Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B9AFC3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 13:18:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19FCD23402
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 13:18:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19FCD23402
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AC2B6B031A; Thu, 22 Aug 2019 09:18:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9369B6B031B; Thu, 22 Aug 2019 09:18:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84B526B031C; Thu, 22 Aug 2019 09:18:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0171.hostedemail.com [216.40.44.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1186B031A
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:18:52 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id F1A8A180AD805
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:18:51 +0000 (UTC)
X-FDA: 75850118862.12.seed62_878b0cb4c9a3c
X-HE-Tag: seed62_878b0cb4c9a3c
X-Filterd-Recvd-Size: 4215
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au [211.29.132.249])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:18:51 +0000 (UTC)
Received: from dread.disaster.area (pa49-181-142-13.pa.nsw.optusnet.com.au [49.181.142.13])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 2D8DF361886;
	Thu, 22 Aug 2019 23:18:47 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1i0myB-0002Bq-P1; Thu, 22 Aug 2019 23:17:39 +1000
Date: Thu, 22 Aug 2019 23:17:39 +1000
From: Dave Chinner <david@fromorbit.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	penguin-kernel@I-love.SAKURA.ne.jp
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
Message-ID: <20190822131739.GB1119@dread.disaster.area>
References: <20190821083820.11725-3-david@fromorbit.com>
 <20190821232440.GB24904@infradead.org>
 <20190822003131.GR1119@dread.disaster.area>
 <20190822075948.GA31346@infradead.org>
 <20190822085130.GI2349@hirez.programming.kicks-ass.net>
 <20190822091057.GK2386@hirez.programming.kicks-ass.net>
 <20190822101441.GY1119@dread.disaster.area>
 <ddcdc274-be61-6e40-5a14-a4faa954f090@suse.cz>
 <20190822120725.GA1119@dread.disaster.area>
 <ad8037c8-d1af-fb4f-1226-af585df492d3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ad8037c8-d1af-fb4f-1226-af585df492d3@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0
	a=pdRIKMFd4+xhzJrg6WzXNA==:117 a=pdRIKMFd4+xhzJrg6WzXNA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=0gar0xGGpDVc-5Bg6r8A:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 02:19:04PM +0200, Vlastimil Babka wrote:
> On 8/22/19 2:07 PM, Dave Chinner wrote:
> > On Thu, Aug 22, 2019 at 01:14:30PM +0200, Vlastimil Babka wrote:
> > 
> > No, the problem is this (using kmalloc as a general term for
> > allocation, whether it be kmalloc, kmem_cache_alloc, alloc_page, etc)
> > 
> >    some random kernel code
> >     kmalloc(GFP_KERNEL)
> >      reclaim
> >      PF_MEMALLOC
> >      shrink_slab
> >       xfs_inode_shrink
> >        XFS_ILOCK
> >         xfs_buf_allocate_memory()
> >          kmalloc(GFP_KERNEL)
> > 
> > And so locks on inodes in reclaim are seen below reclaim. Then
> > somewhere else we have:
> > 
> >    some high level read-only xfs code like readdir
> >     XFS_ILOCK
> >      xfs_buf_allocate_memory()
> >       kmalloc(GFP_KERNEL)
> >        reclaim
> > 
> > And this one throws false positive lockdep warnings because we
> > called into reclaim with XFS_ILOCK held and GFP_KERNEL alloc
> 
> OK, and what exactly makes this positive a false one? Why can't it continue like
> the first example where reclaim leads to another XFS_ILOCK, thus deadlock?

Because above reclaim we only have operations being done on
referenced inodes, and below reclaim we only have unreferenced
inodes. We never lock the same inode both above and below reclaim
at the same time.

IOWs, an operation above reclaim cannot see, access or lock
unreferenced inodes, except in inode write clustering, and that uses
trylocks so cannot deadlock with reclaim.

An operation below reclaim cannot see, access or lock referenced
inodes except during inode write clustering, and that uses trylocks
so cannot deadlock with code above reclaim.

FWIW, I'm trying to make the inode writeback clustering go away from
reclaim at the moment, so even that possibility is going away soon.
That will change everything to trylocks in reclaim context, so
lockdep is going to stop tracking it entirely.

Hmmm - maybe we're getting to the point where we actually
don't need GFP_NOFS/PF_MEMALLOC_NOFS at all in XFS anymore.....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

