Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24A816B0007
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 21:55:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b16so1926984pfi.5
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 18:55:12 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id u10si2013967pgr.221.2018.04.18.18.55.10
        for <linux-mm@kvack.org>;
        Wed, 18 Apr 2018 18:55:11 -0700 (PDT)
Date: Thu, 19 Apr 2018 11:55:08 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419015508.GJ27893@dastard>
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

So while we are talking about schedule suggestions, we see that
there's lots of empty slots in the FS track. We (xfs guys) were just
chatting on #xfs about whether we'd have time to have a "XFS devel
meeting" at some point during LSF/MM as we are rarely in the same
place at the same time.

I'd like to propose that we compact the fs sessions so that we get a
3-slot session reserved for "Individual filesystem discussions" one
afternoon. That way we've got time in the schedule for the all the
ext4/btrfs/XFS/NFS/CIFS devs to get together with each other and
talk about things of interest only to their own fileystems.

That means we all don't have to find time outside the schedule to do
this, and think this wold be time very well spent for most fs people
at the conf....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
