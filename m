Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id A88136B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:43:57 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id r6-v6so1873714uan.7
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:43:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o3-v6sor1850890uae.20.2018.07.18.11.43.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 11:43:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALvZod77dzc2qxQ4=Xc8P-Yup7fks37Nron0WHV_-q9PyoDaBg@mail.gmail.com>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
 <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com>
 <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com>
 <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com>
 <CALvZod5UsYzNs_FJqy2U4HiZ+SdKzKZtzdK1OYcV7v_91kqn8A@mail.gmail.com>
 <CAOm-9aocfOOFODdGn2Gz236_PKaff++6S0U0bTj9eOPnRwM-_w@mail.gmail.com> <CALvZod77dzc2qxQ4=Xc8P-Yup7fks37Nron0WHV_-q9PyoDaBg@mail.gmail.com>
From: Bruce Merry <bmerry@ska.ac.za>
Date: Wed, 18 Jul 2018 20:43:55 +0200
Message-ID: <CAOm-9apU_qYR+nmRur-hdPneuv_Y8v2f_Rub6Tsxc98+AuSiZg@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 18 July 2018 at 20:13, Shakeel Butt <shakeelb@google.com> wrote:
> On Wed, Jul 18, 2018 at 10:58 AM Bruce Merry <bmerry@ska.ac.za> wrote:
> Yes, if there is no memory pressure such memory can stay around.
>
> On your production machine, before deleting memory containers, you can
> try force_empty to reclaim such memory from them. See if that helps.

Thanks. At the moment the cgroups are all managed by systemd and
docker, but I'll keep that in mind while experimenting.

Bruce
-- 
Bruce Merry
Senior Science Processing Developer
SKA South Africa
