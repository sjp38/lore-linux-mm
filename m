Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F10326B027B
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:03:56 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s18so3876661pge.19
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 15:03:56 -0800 (PST)
Received: from out0-248.mail.aliyun.com (out0-248.mail.aliyun.com. [140.205.0.248])
        by mx.google.com with ESMTPS id q9si3539107pll.349.2017.11.17.15.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 15:03:55 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 4/8] vfs: remove unused hardirq.h
Date: Sat, 18 Nov 2017 07:02:17 +0800
Message-Id: <1510959741-31109-4-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Yang Shi <yang.s@alibaba-inc.com>, Alexander Viro <viro@zeniv.linux.org.uk>

Preempt counter APIs have been split out, currently, hardirq.h just
includes irq_enter/exit APIs which are not used by vfs at all.

So, remove the unused hardirq.h.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
---
 fs/dcache.c     | 1 -
 fs/file_table.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index f901413..9340e8c 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -32,7 +32,6 @@
 #include <linux/swap.h>
 #include <linux/bootmem.h>
 #include <linux/fs_struct.h>
-#include <linux/hardirq.h>
 #include <linux/bit_spinlock.h>
 #include <linux/rculist_bl.h>
 #include <linux/prefetch.h>
diff --git a/fs/file_table.c b/fs/file_table.c
index 61517f5..dab099e 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -23,7 +23,6 @@
 #include <linux/sysctl.h>
 #include <linux/percpu_counter.h>
 #include <linux/percpu.h>
-#include <linux/hardirq.h>
 #include <linux/task_work.h>
 #include <linux/ima.h>
 #include <linux/swap.h>
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
