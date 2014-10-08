Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB786B009A
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 10:08:12 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x13so11525936wgg.6
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 07:08:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yx2si242514wjc.11.2014.10.08.07.08.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 07:08:11 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/3] freezer: remove obsolete comments in __thaw_task()
Date: Wed,  8 Oct 2014 16:07:45 +0200
Message-Id: <1412777266-8251-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1412777266-8251-1-git-send-email-mhocko@suse.cz>
References: <1412777266-8251-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

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
index 77ad6794b610..190d667f4e12 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -161,12 +161,6 @@ void __thaw_task(struct task_struct *p)
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
