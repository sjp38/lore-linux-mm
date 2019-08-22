Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69FD1C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 12:08:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36B5322CE3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 12:08:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36B5322CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA0E56B030B; Thu, 22 Aug 2019 08:08:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2B626B030C; Thu, 22 Aug 2019 08:08:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF1436B030D; Thu, 22 Aug 2019 08:08:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0025.hostedemail.com [216.40.44.25])
	by kanga.kvack.org (Postfix) with ESMTP id 86E9F6B030B
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:08:37 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2463755F8E
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 12:08:37 +0000 (UTC)
X-FDA: 75849941874.03.war23_68409c9351c1c
X-HE-Tag: war23_68409c9351c1c
X-Filterd-Recvd-Size: 4670
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au [211.29.132.246])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 12:08:36 +0000 (UTC)
Received: from dread.disaster.area (pa49-195-190-67.pa.nsw.optusnet.com.au [49.195.190.67])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 0F95943D5BA;
	Thu, 22 Aug 2019 22:08:33 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1i0lsD-0001HS-PS; Thu, 22 Aug 2019 22:07:25 +1000
Date: Thu, 22 Aug 2019 22:07:25 +1000
From: Dave Chinner <david@fromorbit.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	penguin-kernel@I-love.SAKURA.ne.jp
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
Message-ID: <20190822120725.GA1119@dread.disaster.area>
References: <20190821083820.11725-1-david@fromorbit.com>
 <20190821083820.11725-3-david@fromorbit.com>
 <20190821232440.GB24904@infradead.org>
 <20190822003131.GR1119@dread.disaster.area>
 <20190822075948.GA31346@infradead.org>
 <20190822085130.GI2349@hirez.programming.kicks-ass.net>
 <20190822091057.GK2386@hirez.programming.kicks-ass.net>
 <20190822101441.GY1119@dread.disaster.area>
 <ddcdc274-be61-6e40-5a14-a4faa954f090@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddcdc274-be61-6e40-5a14-a4faa954f090@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0
	a=TR82T6zjGmBjdfWdGgpkDw==:117 a=TR82T6zjGmBjdfWdGgpkDw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=V1zUpsxUg0v6GzAxzzcA:9 a=am8H9Ncsn3_kpSb4:21
	a=ErFzJFp84WSt4wtB:21 a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 01:14:30PM +0200, Vlastimil Babka wrote:
> On 8/22/19 12:14 PM, Dave Chinner wrote:
> > On Thu, Aug 22, 2019 at 11:10:57AM +0200, Peter Zijlstra wrote:
> >> 
> >> Ah, current_gfp_context() already seems to transfer PF_MEMALLOC_NOFS
> >> into the GFP flags.
> >> 
> >> So are we sure it is broken and needs mending?
> > 
> > Well, that's what we are trying to work out. The problem is that we
> > have code that takes locks and does allocations that is called both
> > above and below the reclaim "lock" context. Once it's been seen
> > below the reclaim lock context, calling it with GFP_KERNEL context
> > above the reclaim lock context throws a deadlock warning.
> > 
> > The only way around that was to mark these allocation sites as
> > GFP_NOFS so lockdep is never allowed to see that recursion through
> > reclaim occur. Even though it isn't a deadlock vector.
> > 
> > What we're looking at is whether PF_MEMALLOC_NOFS changes this - I
> > don't think it does solve this problem. i.e. if we define the
> > allocation as GFP_KERNEL and then use PF_MEMALLOC_NOFS where reclaim
> > is not allowed, we still have GFP_KERNEL allocations in code above
> > reclaim that has also been seen below relcaim. And so we'll get
> > false positive warnings again.
> 
> If I understand both you and the code directly, the code sites won't call
> __fs_reclaim_acquire when called with current->flags including PF_MEMALLOC_NOFS.
> So that would mean they "won't be seen below the reclaim" and all would be fine,
> right?

No, the problem is this (using kmalloc as a general term for
allocation, whether it be kmalloc, kmem_cache_alloc, alloc_page, etc)

   some random kernel code
    kmalloc(GFP_KERNEL)
     reclaim
     PF_MEMALLOC
     shrink_slab
      xfs_inode_shrink
       XFS_ILOCK
        xfs_buf_allocate_memory()
         kmalloc(GFP_KERNEL)

And so locks on inodes in reclaim are seen below reclaim. Then
somewhere else we have:

   some high level read-only xfs code like readdir
    XFS_ILOCK
     xfs_buf_allocate_memory()
      kmalloc(GFP_KERNEL)
       reclaim

And this one throws false positive lockdep warnings because we
called into reclaim with XFS_ILOCK held and GFP_KERNEL alloc
context. So the only solution we had at the tiem to shut it up was:

   some high level read-only xfs code like readdir
    XFS_ILOCK
     xfs_buf_allocate_memory()
      kmalloc(GFP_NOFS)

So that lockdep sees it's not going to recurse into reclaim and
doesn't throw a warning...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

