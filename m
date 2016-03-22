Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id E49056B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:00:41 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id l68so157740204wml.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:00:41 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id c12si13952904wmd.117.2016.03.22.04.00.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 04:00:40 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id u125so2593430wmg.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:00:40 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/9] oom reaper v6
Date: Tue, 22 Mar 2016 12:00:17 +0100
Message-Id: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>

Hi,
I am reposting the whole patchset on top of the current Linus tree which should
already contain big pile of Andrew's mm patches. This should serve an easier
reviewability and I also hope that this core part of the work can go to 4.6.

The previous version was posted here [1] Hugh and David have suggested to
drop [2] because the munlock path currently depends on the page lock and
it is better if the initial version was conservative and prevent from
any potential lockups even though it is not clear whether they are real
- nobody has seen oom_reaper stuck on the page lock AFAICK. Me or Hugh
will have a look and try to make the munlock path not depend on the page
lock as a follow up work.

Apart from that the feedback revealed one bug for a very unusual
configuration (sysctl_oom_kill_allocating_task) and that has been fixed
by patch 8 and one potential mis interaction with the pm freezer fixed by
patch 7.

I think the current code base is already very useful for many situations.
The rest of the feedback was mostly about potential enhancements of the
current code which I would really prefer to build on top of the current
series. I plan to finish my mmap_sem killable for write in the upcoming
release cycle and hopefully have it merged in the next merge window.
I believe more extensions will follow.

This code has been sitting in the mmotm (thus linux-next) for a while.
Are there any fundamental objections to have this part merged in this
merge window?

Thanks!

[1] http://lkml.kernel.org/r/1454505240-23446-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/1454505240-23446-3-git-send-email-mhocko@kernel.org


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
