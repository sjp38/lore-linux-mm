Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84FC86B0069
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 12:41:49 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y42so1836817wrd.23
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 09:41:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u4sor1807616wrg.37.2017.11.17.09.41.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 09:41:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171117173521.GA21692@infradead.org>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171117173521.GA21692@infradead.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 17 Nov 2017 09:41:46 -0800
Message-ID: <CALvZod7Mrs8=5A2j=x96vaUcjCMSxVYi6RVLaKF23UENcAPLvw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 17, 2017 at 9:35 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Nov 14, 2017 at 06:37:42AM +0900, Tetsuo Handa wrote:
>> Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
>> using one RCU section. But using atomic_inc()/atomic_dec() for each
>> do_shrink_slab() call will not impact so much.
>
> But you could use SRCU..

I looked into that but was advised to not go through that route due to
SRCU behind the CONFIG_SRCU. However now I see the precedence of
"#ifdef CONFIG_SRCU" in drivers/base/core.c and I think if we can take
that route if even after Minchan's patch the issue persists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
