Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 825E1C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:15:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AF87206BB
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:15:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AF87206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D71E6B02F1; Thu, 22 Aug 2019 06:15:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 888406B02F2; Thu, 22 Aug 2019 06:15:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74FBE6B02F3; Thu, 22 Aug 2019 06:15:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE1F6B02F1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:15:54 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D0FFC6D66
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:15:53 +0000 (UTC)
X-FDA: 75849657786.03.rake45_8ab2b36520157
X-HE-Tag: rake45_8ab2b36520157
X-Filterd-Recvd-Size: 5094
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au [211.29.132.249])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:15:52 +0000 (UTC)
Received: from dread.disaster.area (pa49-195-190-67.pa.nsw.optusnet.com.au [49.195.190.67])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 6B637360DD4;
	Thu, 22 Aug 2019 20:15:49 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1i0k77-0008VY-Sg; Thu, 22 Aug 2019 20:14:41 +1000
Date: Thu, 22 Aug 2019 20:14:41 +1000
From: Dave Chinner <david@fromorbit.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	penguin-kernel@I-love.SAKURA.ne.jp
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
Message-ID: <20190822101441.GY1119@dread.disaster.area>
References: <20190821083820.11725-1-david@fromorbit.com>
 <20190821083820.11725-3-david@fromorbit.com>
 <20190821232440.GB24904@infradead.org>
 <20190822003131.GR1119@dread.disaster.area>
 <20190822075948.GA31346@infradead.org>
 <20190822085130.GI2349@hirez.programming.kicks-ass.net>
 <20190822091057.GK2386@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822091057.GK2386@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0
	a=TR82T6zjGmBjdfWdGgpkDw==:117 a=TR82T6zjGmBjdfWdGgpkDw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=Bi6Kc3tJZaiG_sx6kGYA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 11:10:57AM +0200, Peter Zijlstra wrote:
> On Thu, Aug 22, 2019 at 10:51:30AM +0200, Peter Zijlstra wrote:
> > On Thu, Aug 22, 2019 at 12:59:48AM -0700, Christoph Hellwig wrote:
> > > On Thu, Aug 22, 2019 at 10:31:32AM +1000, Dave Chinner wrote:
> > > > > Btw, I think we should eventually kill off KM_NOFS and just use
> > > > > PF_MEMALLOC_NOFS in XFS, as the interface makes so much more sense.
> > > > > But that's something for the future.
> > > > 
> > > > Yeah, and it's not quite as simple as just using PF_MEMALLOC_NOFS
> > > > at high levels - we'll still need to annotate callers that use KM_NOFS
> > > > to avoid lockdep false positives. i.e. any code that can be called from
> > > > GFP_KERNEL and reclaim context will throw false positives from
> > > > lockdep if we don't annotate tehm correctly....
> > > 
> > > Oh well.  For now we have the XFS kmem_wrappers to turn that into
> > > GFP_NOFS so we shouldn't be too worried, but I think that is something
> > > we should fix in lockdep to ensure it is generally useful.  I've added
> > > the maintainers and relevant lists to kick off a discussion.
> > 
> > Strictly speaking the fs_reclaim annotation is no longer part of the
> > lockdep core, but is simply a fake lock in page_alloc.c and thus falls
> > under the mm people's purview.
> > 
> > That said; it should be fairly straight forward to teach
> > __need_fs_reclaim() about PF_MEMALLOC_NOFS, much like how it already
> > knows about PF_MEMALLOC.
> 
> Ah, current_gfp_context() already seems to transfer PF_MEMALLOC_NOFS
> into the GFP flags.
> 
> So are we sure it is broken and needs mending?

Well, that's what we are trying to work out. The problem is that we
have code that takes locks and does allocations that is called both
above and below the reclaim "lock" context. Once it's been seen
below the reclaim lock context, calling it with GFP_KERNEL context
above the reclaim lock context throws a deadlock warning.

The only way around that was to mark these allocation sites as
GFP_NOFS so lockdep is never allowed to see that recursion through
reclaim occur. Even though it isn't a deadlock vector.

What we're looking at is whether PF_MEMALLOC_NOFS changes this - I
don't think it does solve this problem. i.e. if we define the
allocation as GFP_KERNEL and then use PF_MEMALLOC_NOFS where reclaim
is not allowed, we still have GFP_KERNEL allocations in code above
reclaim that has also been seen below relcaim. And so we'll get
false positive warnings again.

What I think we are going to have to do here is manually audit
each of the KM_NOFS call sites as we remove the NOFS from them and
determine if ___GFP_NOLOCKDEP is needed to stop lockdep from trying
to track these allocation sites. We've never used this tag because
we'd already fixed most of these false positives with explicit
GFP_NOFS tags long before ___GFP_NOLOCKDEP was created.

But until someone starts doing the work, I don't know if it will
work or even whether conversion PF_MEMALLOC_NOFS is going to
introduce a bunch of new ways to get false positives from lockdep...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

