Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC006B0008
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 02:41:37 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id c4-v6so157671uan.21
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 23:41:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q16-v6sor160181uaq.127.2018.07.25.23.41.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 23:41:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <dda7b095-db84-7e69-a03e-d8ce64fc9b8e@gmail.com>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
 <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com>
 <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com>
 <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com> <dda7b095-db84-7e69-a03e-d8ce64fc9b8e@gmail.com>
From: Bruce Merry <bmerry@ska.ac.za>
Date: Thu, 26 Jul 2018 08:41:35 +0200
Message-ID: <CAOm-9ar2zzxZvZ9A0Yu0knn_LNcHsck72wXShFXutYvAN2qu9Q@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Singh, Balbir" <bsingharora@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 26 July 2018 at 02:55, Singh, Balbir <bsingharora@gmail.com> wrote:
> Do you by any chance have use_hierarch=1? memcg_stat_show should just rely on counters inside the memory cgroup and the the LRU sizes for each node.

Yes, /sys/fs/cgroup/memory/memory.use_hierarchy is 1. I assume systemd
is doing that.

Bruce
-- 
Bruce Merry
Senior Science Processing Developer
SKA South Africa
