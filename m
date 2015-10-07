Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A96FF6B0254
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 11:56:40 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so25138228pad.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 08:56:40 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id wa5si58748251pab.64.2015.10.07.08.56.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 08:56:39 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so25102769pab.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 08:56:39 -0700 (PDT)
References: <20151007005820.54a0b2da.akpm@linux-foundation.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] memcg: convert threshold to bytes
In-reply-to: <20151007005820.54a0b2da.akpm@linux-foundation.org>
Date: Wed, 07 Oct 2015 08:56:34 -0700
Message-ID: <xr93bnca1xl9.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>


Andrew Morton wrote:

> On Wed, 7 Oct 2015 09:30:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>
>> On Tue 06-10-15 12:22:25, Andrew Morton wrote:
>> > On Tue, 6 Oct 2015 19:01:23 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>> > 
>> > > On Mon 05-10-15 14:44:22, Shaohua Li wrote:
>> > > > The page_counter_memparse() returns pages for the threshold, while
>> > > > mem_cgroup_usage() returns bytes for memory usage. Convert the threshold
>> > > > to bytes.
>> > > > 
>> > > > Looks a regression introduced by 3e32cb2e0a12b69150
>> > > 
>> > > Yes. This suggests
>> > > Cc: stable # 3.19+
>> > 
>> > But it's been this way for 2 years and nobody noticed it.  How come?
>> 
>> Maybe we do not have that many users of this API with newer kernels.
>
> Either it's zero or all the users have worked around this bug.
>
>> > Or at least, nobody reported it.  Maybe people *have* noticed it, and
>> > adjusted their userspace appropriately.  In which case this patch will
>> > cause breakage.
>> 
>> I dunno, I would rather have it fixed than keep bug to bug compatibility
>> because they would eventually move to a newer kernel one day when they
>> see the "breakage" anyway.
>
> They'd only see breakage if we fixed this in the newer kernel.
>
> We could just change the docs and leave it as-is.  That it is called
> "usage_in_bytes" makes that a bit awkward.
>
> A bit of googling indicates that people are using usage_in_bytes.  A
> few.  All the discussions I found clearly predate this bug.
>
> So did people just stop using this?  Is there some alternative way of
> getting the same info?

We (Google) are using byte based notifications on memory.limit_in_bytes
on a pre 3e32cb2e0a12b69150 kernel.  So we'd notice the regression when
running newer kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
