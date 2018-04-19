Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3E46B0009
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:52:05 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w3-v6so3566550qtn.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:52:05 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l41-v6si2638269qtc.246.2018.04.19.07.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 07:52:04 -0700 (PDT)
From: Chris Mason <clm@fb.com>
Subject: Re: [LSF/MM] schedule suggestion
Date: Thu, 19 Apr 2018 10:51:45 -0400
Message-ID: <D8E1F46B-ACC2-4072-A4D1-769A6B4F40F4@fb.com>
In-Reply-To: <20180419015508.GJ27893@dastard>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
MIME-Version: 1.0
Content-Type: text/plain; markup=markdown
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On 18 Apr 2018, at 21:55, Dave Chinner wrote:

> On Wed, Apr 18, 2018 at 05:19:39PM -0400, Jerome Glisse wrote:
>> Just wanted to suggest to push HMM status down one slot in the
>> agenda to avoid having FS and MM first going into their own
>> room and then merging back for GUP and DAX, and re-splitting
>> after. More over HMM and NUMA talks will be good to have back
>> to back as they deal with same kind of thing mostly.
>
> So while we are talking about schedule suggestions, we see that
> there's lots of empty slots in the FS track. We (xfs guys) were just
> chatting on #xfs about whether we'd have time to have a "XFS devel
> meeting" at some point during LSF/MM as we are rarely in the same
> place at the same time.
>
> I'd like to propose that we compact the fs sessions so that we get a
> 3-slot session reserved for "Individual filesystem discussions" one
> afternoon. That way we've got time in the schedule for the all the
> ext4/btrfs/XFS/NFS/CIFS devs to get together with each other and
> talk about things of interest only to their own fileystems.
>
> That means we all don't have to find time outside the schedule to do
> this, and think this wold be time very well spent for most fs people
> at the conf....

I'd love this as well.

-chris
