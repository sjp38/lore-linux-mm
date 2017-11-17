Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19CFC6B027B
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:03:40 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 207so3871366pgc.21
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 15:03:40 -0800 (PST)
Received: from out0-242.mail.aliyun.com (out0-242.mail.aliyun.com. [140.205.0.242])
        by mx.google.com with ESMTPS id h6si3610594pln.14.2017.11.17.15.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 15:03:39 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 2/8] fs: pstore: remove unused hardirq.h
Date: Sat, 18 Nov 2017 07:02:15 +0800
Message-Id: <1510959741-31109-2-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Yang Shi <yang.s@alibaba-inc.com>, Kees Cook <keescook@chromium.org>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>

Preempt counter APIs have been split out, currently, hardirq.h just
includes irq_enter/exit APIs which are not used by pstore at all.

So, remove the unused hardirq.h.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Anton Vorontsov <anton@enomsg.org>
Cc: Colin Cross <ccross@android.com>
Cc: Tony Luck <tony.luck@intel.com>
---
 fs/pstore/platform.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/pstore/platform.c b/fs/pstore/platform.c
index 2b21d18..25dcef4 100644
--- a/fs/pstore/platform.c
+++ b/fs/pstore/platform.c
@@ -41,7 +41,6 @@
 #include <linux/timer.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
-#include <linux/hardirq.h>
 #include <linux/jiffies.h>
 #include <linux/workqueue.h>
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
