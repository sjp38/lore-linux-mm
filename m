Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 114776B04C1
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 13:32:40 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id p77so1609286ywp.3
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 10:32:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i10sor236736ywg.500.2017.09.04.10.32.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Sep 2017 10:32:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170904142108.7165-6-guro@fb.com>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-6-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 4 Sep 2017 10:32:37 -0700
Message-ID: <CALvZod4TtA8myYSqCL87dDXfyk1qkYx+v-MO6nt-cA+bKTcGUA@mail.gmail.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 4, 2017 at 7:21 AM, Roman Gushchin <guro@fb.com> wrote:
> Introducing of cgroup-aware OOM killer changes the victim selection
> algorithm used by default: instead of picking the largest process,
> it will pick the largest memcg and then the largest process inside.
>
> This affects only cgroup v2 users.
>
> To provide a way to use cgroups v2 if the old OOM victim selection
> algorithm is preferred for some reason, the nogroupoom mount option
> is added.

Is this mount option or boot parameter? From the code, it seems like a
boot parameter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
