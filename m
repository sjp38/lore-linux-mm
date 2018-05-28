Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E38A6B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 13:23:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n18-v6so10726887wrm.7
        for <linux-mm@kvack.org>; Mon, 28 May 2018 10:23:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor15025668wry.4.2018.05.28.10.23.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 May 2018 10:23:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180528091110.GG1517@dhcp22.suse.cz>
References: <20180525185501.82098-1-shakeelb@google.com> <20180526185144.xvh7ejlyelzvqwdb@esperanza>
 <CALvZod5yTxcuB_Aao-a0ChNEnwyBJk9UPvEQ80s9tZFBQ0cxpw@mail.gmail.com> <20180528091110.GG1517@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 28 May 2018 10:23:07 -0700
Message-ID: <CALvZod6x5iRmcJ6pYKS+jwJd855jnwmVcPK9tnKbuJ9Hfppa-A@mail.gmail.com>
Subject: Re: [PATCH] memcg: force charge kmem counter too
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 28, 2018 at 2:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Sat 26-05-18 15:37:05, Shakeel Butt wrote:
>> On Sat, May 26, 2018 at 11:51 AM, Vladimir Davydov
>> <vdavydov.dev@gmail.com> wrote:
>> > On Fri, May 25, 2018 at 11:55:01AM -0700, Shakeel Butt wrote:
>> >> Based on several conditions the kernel can decide to force charge an
>> >> allocation for a memcg i.e. overcharge memcg->memory and memcg->memsw
>> >> counters. Do the same for memcg->kmem counter too. In cgroup-v1, this
>> >> bug can cause a __GFP_NOFAIL kmem allocation fail if an explicit limit
>> >> on kmem counter is set and reached.
>> >
>> > memory.kmem.limit is broken and unlikely to ever be fixed as this knob
>> > was deprecated in cgroup-v2. The fact that hitting the limit doesn't
>> > trigger reclaim can result in unexpected behavior from user's pov, like
>> > getting ENOMEM while listing a directory. Bypassing the limit for NOFAIL
>> > allocations isn't going to fix those problem.
>>
>> I understand that fixing NOFAIL will not fix all other issues but it
>> still is better than current situation. IMHO we should keep fixing
>> kmem bit by bit.
>>
>> One crazy idea is to just break it completely by force charging all the time.
>
> What is the limit good for then? Accounting?
>

Unlike tcpmem, the kmem accounting is enabled by default. No need to
set the limit to enable accounting.

I think my crazy idea was just wrong and without much thought. Though
is there a precedence where the broken feature is not fixed because an
alternative is available?
