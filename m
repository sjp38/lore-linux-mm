Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95DBA6B0011
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 11:08:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e14so2931894pfi.9
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 08:08:15 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f4-v6si162842plm.448.2018.04.19.08.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 08:08:14 -0700 (PDT)
Subject: Re: [LSF/MM] schedule suggestion
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <20180418211939.GD3476@redhat.com>
	<20180419015508.GJ27893@dastard>
	<D8E1F46B-ACC2-4072-A4D1-769A6B4F40F4@fb.com>
Date: Thu, 19 Apr 2018 11:07:58 -0400
In-Reply-To: <D8E1F46B-ACC2-4072-A4D1-769A6B4F40F4@fb.com> (Chris Mason's
	message of "Thu, 19 Apr 2018 10:51:45 -0400")
Message-ID: <yq1vacnjktt.fsf@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: Dave Chinner <david@fromorbit.com>, Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>


Chris,

>> I'd like to propose that we compact the fs sessions so that we get a
>> 3-slot session reserved for "Individual filesystem discussions" one
>> afternoon. That way we've got time in the schedule for the all the
>> ext4/btrfs/XFS/NFS/CIFS devs to get together with each other and
>> talk about things of interest only to their own fileystems.
>>
>> That means we all don't have to find time outside the schedule to do
>> this, and think this wold be time very well spent for most fs people
>> at the conf....
>
> I'd love this as well.

Based on feedback last year we explicitly added a third day to LSF/MM to
facilitate hack time and project meetings.

As usual the schedule is fluid and will be adjusted on the fly.
Depending on track, I am hoping we'll be done with the scheduled topics
either at the end of Tuesday or Wednesday morning.

-- 
Martin K. Petersen	Oracle Linux Engineering
