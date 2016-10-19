Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 082196B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:30:25 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ry6so7603436pac.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 22:30:24 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id w12si38817665pfd.37.2016.10.18.22.30.23
        for <linux-mm@kvack.org>;
        Tue, 18 Oct 2016 22:30:24 -0700 (PDT)
Date: Wed, 19 Oct 2016 16:30:20 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20161019053020.GK14023@dastard>
References: <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20161006130454.GI10570@dhcp22.suse.cz>
 <20161019003309.GG23194@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019003309.GG23194@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

[resend with the xfs list corrected.]

On Thu, Oct 06, 2016 at 03:04:54PM +0200, Michal Hocko wrote:
> [Let me ressurect this thread]
> 
> On Wed 01-06-16 20:16:17, Peter Zijlstra wrote:
> > On Wed, Jun 01, 2016 at 03:17:58PM +0200, Michal Hocko wrote:
> > > Thanks Dave for your detailed explanation again! Peter do you have any
> > > other idea how to deal with these situations other than opt out from
> > > lockdep reclaim machinery?
> > > 
> > > If not I would rather go with an annotation than a gfp flag to be honest
> > > but if you absolutely hate that approach then I will try to check wheter
> > > a CONFIG_LOCKDEP GFP_FOO doesn't break something else. Otherwise I would
> > > steal the description from Dave's email and repost my patch.
> > > 
> > > I plan to repost my scope gfp patches in few days and it would be good
> > > to have some mechanism to drop those GFP_NOFS to paper over lockdep
> > > false positives for that.
> > 
> > Right; sorry I got side-tracked in other things again.
> > 
> > So my favourite is the dedicated GFP flag, but if that's unpalatable for
> > the mm folks then something like the below might work. It should be
> > similar in effect to your proposal, except its more limited in scope.
> 
> OK, so the situation with the GFP flags is somehow relieved after 
> http://lkml.kernel.org/r/20160912114852.GI14524@dhcp22.suse.cz and with
> the root radix tree remaining the last user which mangles gfp_mask and
> tags together we have some few bits left there. As you apparently hate
> any scoped API and Dave thinks that per allocation flag is the only
> maintainable way for xfs what do you think about the following?

It's a workable solution to allow XFS to play whack-a-mole games
with lockdep again. As to the implementation - that's for other
people to decide....

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
