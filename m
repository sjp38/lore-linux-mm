Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 325B96B0255
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:12:29 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so26949925wml.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:12:29 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id a2si4317618wmc.91.2016.03.08.05.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 05:12:28 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id p65so3978359wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:12:27 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm-oom_reaper-report-success-failure-fix-fix
Date: Tue,  8 Mar 2016 14:12:16 +0100
Message-Id: <1457442737-8915-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

typo fix

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 09e6f3211f1c..70fff7e3b1a7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -480,7 +480,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		}
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
-	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lulB\n",
+	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
