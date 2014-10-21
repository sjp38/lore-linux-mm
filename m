Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCAF6B0070
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 03:27:37 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id bs8so145322wib.5
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 00:27:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si11177147wia.1.2014.10.21.00.27.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 00:27:35 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/4] freezer: remove obsolete comments in __thaw_task()
Date: Tue, 21 Oct 2014 09:27:13 +0200
Message-Id: <1413876435-11720-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

__thaw_task() no longer clears frozen flag since commit a3201227f803
(freezer: make freezing() test freeze conditions in effect instead of TIF_FREEZE).

Cc: David Rientjes <rientjes@google.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 kernel/freezer.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/kernel/freezer.c b/kernel/freezer.c
index 8f9279b9c6d7..a8900a3bc27a 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -150,12 +150,6 @@ void __thaw_task(struct task_struct *p)
 {
 	unsigned long flags;
 
-	/*
-	 * Clear freezing and kick @p if FROZEN.  Clearing is guaranteed to
-	 * be visible to @p as waking up implies wmb.  Waking up inside
-	 * freezer_lock also prevents wakeups from leaking outside
-	 * refrigerator.
-	 */
 	spin_lock_irqsave(&freezer_lock, flags);
 	if (frozen(p))
 		wake_up_process(p);
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
