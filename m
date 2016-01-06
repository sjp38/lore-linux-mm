Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 687AE800C7
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 10:43:08 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id u188so64761886wmu.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:43:08 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id k8si12537499wmd.56.2016.01.06.07.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 07:43:07 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id f206so64084549wmf.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:43:07 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2 -mm] oom reaper v4
Date: Wed,  6 Jan 2016 16:42:53 +0100
Message-Id: <1452094975-551-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
the number of -fix patches for the the v3 of the patch [1] has grown
quite a bit... so this is a drop in replacement for 
mm-oom-introduce-oom-reaper.patch
mm-oom-introduce-oom-reaper-fix.patch
mm-oom-introduce-oom-reaper-fix-fix.patch
mm-oom-introduce-oom-reaper-fix-fix-2.patch
mm-oom-introduce-oom-reaper-checkpatch-fixes.patch
mm-oom-introduce-oom-reaper-fix-3.patch
mm-oom-introduce-oom-reaper-fix-4.patch
mm-oom-introduce-oom-reaper-fix-4-fix.patch
mm-oom-introduce-oom-reaper-fix-5.patch
mm-oom-introduce-oom-reaper-fix-5-fix.patch
mm-oom-introduce-oom-reaper-fix-6.patch

I belive this should make the further review easier. I have put an
additional patch on top which allows to munlock & unmap anonymous
mappings as well. This went to a separate patch for an easier
bisectability.

[1] http://lkml.kernel.org/r/1450204575-13052-1-git-send-email-mhocko%40kernel.org

Michal Hocko (2):
      mm, oom: introduce oom reaper
      oom reaper: handle anonymous mlocked pages

Diffstat says:
 include/linux/mm.h |   2 +
 mm/internal.h      |   5 ++
 mm/memory.c        |  17 +++---
 mm/oom_kill.c      | 162 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 175 insertions(+), 11 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
