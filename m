Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B47276B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 12:03:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so12250906wmw.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 09:03:45 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id jd1si22781146wjb.248.2016.05.13.09.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 09:03:43 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so4564099wmw.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 09:03:43 -0700 (PDT)
Date: Fri, 13 May 2016 18:03:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160513160341.GW20141@dhcp22.suse.cz>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160512080321.GA18496@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

On Thu 12-05-16 18:03:21, Dave Chinner wrote:
> [ cc Michal Hocko, just so he can see a lockdep reclaim state false
> positive ]

Thank you for CCing me!

I am sorry I didn't follow up on the previous discussion but I got side
tracked by something else. I have tried to cook up something really
simply. I didn't get to test it at all and it might be completely broken
but I just wanted to throw an idea for the discussion. I am CCing Peter
as well - he might have a better idea (the reference to the full email
is in the changelog. Is something like the following correct/acceptable?

This is on top of my scope gfp_nofs patch I have posted recently but I
can reorder them if this looks ok.
---
