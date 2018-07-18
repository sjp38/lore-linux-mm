Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 626C16B0007
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:40:22 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id u26-v6so1793054uan.23
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:40:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t90-v6sor1811581uat.170.2018.07.18.10.40.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 10:40:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
 <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com> <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com>
From: Bruce Merry <bmerry@ska.ac.za>
Date: Wed, 18 Jul 2018 19:40:20 +0200
Message-ID: <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 18 July 2018 at 17:49, Shakeel Butt <shakeelb@google.com> wrote:
> On Wed, Jul 18, 2018 at 8:37 AM Bruce Merry <bmerry@ska.ac.za> wrote:
>> That sounds promising. Is there any way to tell how many zombies there
>> are, and is there any way to deliberately create zombies? If I can
>> produce zombies that might give me a reliable way to reproduce the
>> problem, which could then sensibly be tested against newer kernel
>> versions.
>>
>
> Yes, very easy to produce zombies, though I don't think kernel
> provides any way to tell how many zombies exist on the system.
>
> To create a zombie, first create a memcg node, enter that memcg,
> create a tmpfs file of few KiBs, exit the memcg and rmdir the memcg.
> That memcg will be a zombie until you delete that tmpfs file.

Thanks, that makes sense. I'll see if I can reproduce the issue. Do
you expect the same thing to happen with normal (non-tmpfs) files that
are sitting in the page cache, and/or dentries?

Cheers
Bruce
-- 
Bruce Merry
Senior Science Processing Developer
SKA South Africa
