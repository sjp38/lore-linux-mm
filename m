Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D1F18828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:14:07 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id r129so164478330wmr.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:07 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id q200si12546624wmg.67.2016.02.03.05.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 05:14:06 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id r129so7371978wmr.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:06 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/5] oom reaper v5
Date: Wed,  3 Feb 2016 14:13:55 +0100
Message-Id: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I am reposting the whole patchset on top of mmotm with the previous
version of the patchset reverted for an easier review. The series
applies cleanly on top of the current Linus tree as well.

The previous version was posted http://lkml.kernel.org/r/1452094975-551-1-git-send-email-mhocko@kernel.org
I have tried to address most of the feedback. There was some push
for extending the current implementation further but I do not feel
comfortable to do that right now. I believe that we should start
as easy as possible and add extensions on top. That shouldn't be
hard with the current architecture.

Wrt. the previous version, I have added patches 4 and 5. Patch4 reports
success/failures to reap a task which is useful to see how the reaper
operates. Patch 5 is implementing a more robust API between the oom
killer and the oom reaper. We allow more tasks to be queued for the
reaper at the same time rather than the original signle task mode.

Patch 1 also dropped oom_reaper thread priority handling as per
David.  I ended up keeping vma filtering code inside __oom_reap_task.
I still believe this is a better fit because the rules are a single
fit for the reaper. They cannot be shared with a larger code base.

In the meantime I have prepared down_write_killable rw_semaphore
variant http://lkml.kernel.org/r/1454444369-2146-1-git-send-email-mhocko@kernel.org
and also have a tentative patch to convert some users of mmap_sem for
write to use the killable version. This needs more checking though but
I guess I will have something ready in 2 weeks or so (I will be on
vacation next week).

For the general description of the oom_reaper functionality, please
refer to Patch1.

I would be really greatful if we could postpone any
functional/semantical enhancements for later discussion and focus on the
correctness of these particular patches as there were no fundamental
objectios to the current approach.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
