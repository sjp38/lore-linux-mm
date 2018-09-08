Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC9668E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 09:36:19 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w185-v6so20527197oig.19
        for <linux-mm@kvack.org>; Sat, 08 Sep 2018 06:36:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a143-v6si8025858oih.126.2018.09.08.06.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Sep 2018 06:36:17 -0700 (PDT)
Subject: Re: [PATCH] mm: memcontrol: print proper OOM header when no eligible
 victim left
References: <20180821160406.22578-1-hannes@cmpxchg.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <b94f9964-c785-20c1-34af-e9013770b89a@I-love.SAKURA.ne.jp>
Date: Sat, 8 Sep 2018 22:36:06 +0900
MIME-Version: 1.0
In-Reply-To: <20180821160406.22578-1-hannes@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On 2018/08/22 1:04, Johannes Weiner wrote:
> When the memcg OOM killer runs out of killable tasks, it currently
> prints a WARN with no further OOM context. This has caused some user
> confusion.
> 
> Warnings indicate a kernel problem. In a reported case, however, the
> situation was triggered by a non-sensical memcg configuration (hard
> limit set to 0). But without any VM context this wasn't obvious from
> the report, and it took some back and forth on the mailing list to
> identify what is actually a trivial issue.
> 
> Handle this OOM condition like we handle it in the global OOM killer:
> dump the full OOM context and tell the user we ran out of tasks.
> 
> This way the user can identify misconfigurations easily by themselves
> and rectify the problem - without having to go through the hassle of
> running into an obscure but unsettling warning, finding the
> appropriate kernel mailing list and waiting for a kernel developer to
> remote-analyze that the memcg configuration caused this.
> 
> If users cannot make sense of why the OOM killer was triggered or why
> it failed, they will still report it to the mailing list, we know that
> from experience. So in case there is an actual kernel bug causing
> this, kernel developers will very likely hear about it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memcontrol.c |  2 --
>  mm/oom_kill.c   | 13 ++++++++++---
>  2 files changed, 10 insertions(+), 5 deletions(-)
> 

Now that above patch went to 4.19-rc3, please apply below one.
