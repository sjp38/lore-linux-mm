Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE226B0037
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 03:42:47 -0400 (EDT)
Received: by mail-yk0-f169.google.com with SMTP id 142so6726408ykq.0
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 00:42:47 -0700 (PDT)
Received: from mail-yk0-x24a.google.com (mail-yk0-x24a.google.com [2607:f8b0:4002:c07::24a])
        by mx.google.com with ESMTPS id y72si11642187yhe.210.2014.04.29.00.42.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 00:42:47 -0700 (PDT)
Received: by mail-yk0-f202.google.com with SMTP id 9so136711ykp.3
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 00:42:46 -0700 (PDT)
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz> <10861398700008@webcorp2f.yandex-team.ru>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
In-reply-to: <10861398700008@webcorp2f.yandex-team.ru>
Date: Tue, 29 Apr 2014 00:42:45 -0700
Message-ID: <xr938uqoa8ei.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


On Mon, Apr 28 2014, Roman Gushchin <klamm@yandex-team.ru> wrote:

> 28.04.2014, 16:27, "Michal Hocko" <mhocko@suse.cz>:
>> The series is based on top of the current mmotm tree. Once the series
>> gets accepted I will post a patch which will mark the soft limit as
>> deprecated with a note that it will be eventually dropped. Let me know
>> if you would prefer to have such a patch a part of the series.
>>
>> Thoughts?
>
>
> Looks good to me.
>
> The only question is: are there any ideas how the hierarchy support
> will be used in this case in practice?
> Will someone set low limit for non-leaf cgroups? Why?
>
> Thanks,
> Roman

I imagine that a hosting service may want to give X MB to a top level
memcg (/a) with sub-jobs (/a/b, /a/c) which may(not) have their own
low-limits.

Examples:

case_1) only set low limit on /a.  /a/b and /a/c may overcommit /a's
        memory (b.limit_in_bytes + c.limit_in_bytes > a.limit_in_bytes).

case_2) low limits on all memcg.  But not overcommitting low_limits
        (b.low_limit_in_in_bytes + c.low_limit_in_in_bytes <=
        a.low_limit_in_in_bytes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
