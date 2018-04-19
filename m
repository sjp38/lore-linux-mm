Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA46D6B0006
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 20:48:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 61-v6so1942921plz.20
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 17:48:21 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id t10-v6si2351121plo.210.2018.04.18.17.48.19
        for <linux-mm@kvack.org>;
        Wed, 18 Apr 2018 17:48:20 -0700 (PDT)
Date: Thu, 19 Apr 2018 10:48:17 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419004817.GH27893@dastard>
References: <20180418211939.GD3476@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418211939.GD3476@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Wed, Apr 18, 2018 at 05:19:39PM -0400, Jerome Glisse wrote:
> Just wanted to suggest to push HMM status down one slot in the
> agenda to avoid having FS and MM first going into their own
> room and then merging back for GUP and DAX, and re-splitting
> after. More over HMM and NUMA talks will be good to have back
> to back as they deal with same kind of thing mostly.

Yeah, I noticed there are a few of these shared sessions that have
been placed in the middle slot of a session. Would be good to put
all the shared fs/mm sessions into a complete session block so
people don't have to keep moving rooms every half hour...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
