Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7726B02B1
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 07:15:01 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id j204so690875lfe.8
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 04:15:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h39sor646918lji.79.2017.11.08.04.14.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 04:14:59 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: Re: [PATCH 1/2] mm: add sysctl to control global OOM logging behaviour
In-Reply-To: <24fb6865-6cc5-2af0-3a99-ea9495791f66@I-love.SAKURA.ne.jp>
References: <20171108091843.29349-1-dmonakhov@openvz.org> <24fb6865-6cc5-2af0-3a99-ea9495791f66@I-love.SAKURA.ne.jp>
Date: Wed, 08 Nov 2017 15:19:50 +0300
Message-ID: <87inelklnd.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, vdavydov.dev@gmail.com

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> On 2017/11/08 18:18, Dmitry Monakhov wrote:
>> Our systems becomes bigger and bigger, but OOM still happens.
>> This becomes serious problem for systems where OOM happens
>> frequently(containers, VM) because each OOM generate pressure
>> on dmesg log infrastructure. Let's allow system administrator
>> ability to tune OOM dump behaviour
>
> Majority of OOM killer related messages are from dump_header().
> Thus, allow tuning __ratelimit(&oom_rs) might make sense.
>
> But other lines
>
>   "%s: Kill process %d (%s) score %u or sacrifice child\n"
>   "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"
>   "oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"
This still may result in hundreds of messages per second.
So it would be nice to have option to disable OOM logging.
> should not cause problems, for it is easy to exclude such lines from
> your dmesg log infrastructure using fgrep match.
In fact I've considered an abbility to use even more
fine grained log level control:
0: no oom log at all
1: dump only single line logs ( from oom_kill_process and reaper_task)
2: 1+ dump headers
3: 2+ task_stack (which previously controlled by sysctl_oom_dump_task)
What do you think?
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
