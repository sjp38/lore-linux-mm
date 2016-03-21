Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 26D626B0253
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 06:56:17 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id ig19so64912547igb.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 03:56:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r18si9329062igs.91.2016.03.21.03.56.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 03:56:16 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Remove undefined oom_kills_count()/note_oom_kill().
Date: Mon, 21 Mar 2016 19:55:43 +0900
Message-Id: <1458557743-4245-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 9e2b524..dad467a 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -76,8 +76,6 @@ extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
 
-extern int oom_kills_count(void);
-extern void note_oom_kill(void);
 extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			     unsigned int points, unsigned long totalpages,
 			     struct mem_cgroup *memcg, const char *message);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
