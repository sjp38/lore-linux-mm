Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6A09D6B0256
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:12:31 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so27001266wmp.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:12:31 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id bm4si3663254wjc.169.2016.03.08.05.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 05:12:28 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id 1so3971121wmg.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:12:28 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2]  oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
Date: Tue,  8 Mar 2016 14:12:17 +0100
Message-Id: <1457442737-8915-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

fix a left over

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 70fff7e3b1a7..b6228643367b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -569,7 +569,7 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static void wake_oom_reaper(struct task_struct *mm)
+static void wake_oom_reaper(struct task_struct *tsk)
 {
 }
 #endif
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
