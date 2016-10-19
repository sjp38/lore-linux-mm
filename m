Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F37A6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 08:06:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m5so18701354qtb.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 05:06:29 -0700 (PDT)
Received: from mail-qt0-f174.google.com (mail-qt0-f174.google.com. [209.85.216.174])
        by mx.google.com with ESMTPS id f62si24080778qkj.1.2016.10.19.05.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 05:06:28 -0700 (PDT)
Received: by mail-qt0-f174.google.com with SMTP id f6so15850152qtd.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 05:06:28 -0700 (PDT)
Date: Wed, 19 Oct 2016 14:06:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20161019120626.GI7517@dhcp22.suse.cz>
References: <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20161006130454.GI10570@dhcp22.suse.cz>
 <20161019083304.GD3102@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019083304.GD3102@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed 19-10-16 10:33:04, Peter Zijlstra wrote:
[...]
> So I'm all for this if this works for Dave.
> 
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Thanks Peter!

> Please take it through the XFS tree which would introduce its first user
> etc..

Dave, does that work for you? I agree that having this followed by a
first user would be really preferable. Maybe to turn some of those added
by b17cb364dbbb? I wish I could help here but as you've said earlier
each such annotation should be accompanied by an explanation which I am
not qualified to provide.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
