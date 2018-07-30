Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7796B0005
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 17:02:15 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m197-v6so11852334oig.18
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:02:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q206-v6si9535244oic.413.2018.07.30.14.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 14:02:13 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
 <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
 <20180730093257.GG24267@dhcp22.suse.cz>
 <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
Date: Tue, 31 Jul 2018 06:01:48 +0900
MIME-Version: 1.0
In-Reply-To: <20180730191005.GC24267@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/07/31 4:10, Michal Hocko wrote:
> Since should_reclaim_retry() should be a natural reschedule point,
> let's do the short sleep for PF_WQ_WORKER threads unconditionally in
> order to guarantee that other pending work items are started. This will
> workaround this problem and it is less fragile than hunting down when
> the sleep is missed. E.g. we used to have a sleeping point in the oom
> path but this has been removed recently because it caused other issues.
> Having a single sleeping point is more robust.

linux.git has not removed the sleeping point in the OOM path yet. Since removing the
sleeping point in the OOM path can mitigate CVE-2016-10723, please do so immediately.
(And that change will conflict with Roman's cgroup aware OOM killer patchset. But it
should be easy to rebase.)
