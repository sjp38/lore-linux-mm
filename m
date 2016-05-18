Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 242676B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 04:25:42 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u64so21345130lff.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:25:42 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id jf6si8957272wjb.6.2016.05.18.01.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 01:25:40 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id n129so172877277wmn.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:25:40 -0700 (PDT)
Date: Wed, 18 May 2016 10:25:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160518082538.GE21654@dhcp22.suse.cz>
References: <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160518072005.GA3193@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518072005.GA3193@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed 18-05-16 09:20:05, Peter Zijlstra wrote:
> On Wed, May 18, 2016 at 08:35:49AM +1000, Dave Chinner wrote:
> > On Tue, May 17, 2016 at 04:49:12PM +0200, Peter Zijlstra wrote:
[...]
> > > In any case; would something like this work for you? Its entirely
> > > untested, but the idea is to mark an entire class to skip reclaim
> > > validation, instead of marking individual sites.
> > 
> > Probably would, but it seems like swatting a fly with runaway
> > train. I'd much prefer a per-site annotation (e.g. as a GFP_ flag)
> > so that we don't turn off something that will tell us we've made a
> > mistake while developing new code...
> 
> Fair enough; if the mm folks don't object to 'wasting' a GFP flag on
> this the below ought to do I think.

GFP flag space is quite scarse. Especially when it would be used only
for lockdep configurations which are mostly disabled. Why cannot we go
with an explicit disable/enable API I have proposed? It would be lockdep
contained and quite easy to grep for and git blame would tell us
(hopefuly) why the lockdep had to be put out of the way for the
particular path.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
