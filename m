Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF7A58E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:15:30 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id k1so10651383ybm.8
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:15:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor2336267ywm.164.2019.01.21.10.15.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 10:15:29 -0800 (PST)
MIME-Version: 1.0
References: <20190120215059.183552-1-shakeelb@google.com> <201901210123.x0L1NLFJ043029@www262.sakura.ne.jp>
In-Reply-To: <201901210123.x0L1NLFJ043029@www262.sakura.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 21 Jan 2019 10:15:18 -0800
Message-ID: <CALvZod7OxOiGgXfC1xjQ0z5GrvMQCVCZ_1=B+B7Ggo-z3+BqEg@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: remove 'prefer children over parent' heuristic
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Jan 20, 2019 at 5:23 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> Shakeel Butt wrote:
> > +     pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> > +             message, task_pid_nr(p), p->comm, oc->chosen_points);
>
> This patch is to make "or sacrifice child" false. And, the process reported
> by this line will become always same with the process reported by
>
>         pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>                 task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
>                 K(get_mm_counter(victim->mm, MM_ANONPAGES)),
>                 K(get_mm_counter(victim->mm, MM_FILEPAGES)),
>                 K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
>
> . Then, better to merge these pr_err() lines?

Thanks, will remove the one in oom_kill_process.
