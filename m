Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 062516B0006
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:48:17 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j28so4048844wrd.17
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:48:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1sor6033wmg.87.2018.03.08.15.48.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Mar 2018 15:48:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180308154501.a42bb22af0da6ccd727773c8@linux-foundation.org>
References: <20180308024850.39737-1-shakeelb@google.com> <20180308154501.a42bb22af0da6ccd727773c8@linux-foundation.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 8 Mar 2018 15:48:14 -0800
Message-ID: <CALvZod5gy8iw-Va7-Gzyqv1xVkTGhU3k4UysktXb7bfbbtUt9Q@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: expose mem_cgroup_put API
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, David Rientjes <rientjes@google.com>

On Thu, Mar 8, 2018 at 3:45 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed,  7 Mar 2018 18:48:50 -0800 Shakeel Butt <shakeelb@google.com> wrote:
>
>> This patch exports mem_cgroup_put API to put the refcnt of the memory
>> cgroup.
>
> OK, I remember now.  This is intended to make
> fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch independent of
> mm-oom-cgroup-aware-oom-killer.patch by extracting mem_cgroup_put()
> from mm-oom-cgroup-aware-oom-killer.patch.

Yes, you are right, it is needed by the above fsnotify patch.

> However it will not permit me to stage
> fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch ahead of
> mm-oom-cgroup-aware-oom-killer.patch because there are quite a lot of
> syntactic clashes.
>
> I can resolve those if needed, but am keenly hoping that the
> mm-oom-cgroup-aware-oom-killer.patch issues are resolved soon so there
> isn't a need to do this.
>

Sounds good to me.
