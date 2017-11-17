Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 468C96B027B
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:04:30 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q126so3890780pgq.7
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 15:04:30 -0800 (PST)
Received: from out0-207.mail.aliyun.com (out0-207.mail.aliyun.com. [140.205.0.207])
        by mx.google.com with ESMTPS id u80si3841854pfd.169.2017.11.17.15.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 15:04:29 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 8/8] net: tipc: remove unused hardirq.h
Date: Sat, 18 Nov 2017 07:02:21 +0800
Message-Id: <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Yang Shi <yang.s@alibaba-inc.com>, Jon Maloy <jon.maloy@ericsson.com>, Ying Xue <ying.xue@windriver.com>, "David S. Miller" <davem@davemloft.net>

Preempt counter APIs have been split out, currently, hardirq.h just
includes irq_enter/exit APIs which are not used by TIPC at all.

So, remove the unused hardirq.h.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Ying Xue <ying.xue@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/tipc/core.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 5cc5398..099e072 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -49,7 +49,6 @@
 #include <linux/uaccess.h>
 #include <linux/interrupt.h>
 #include <linux/atomic.h>
-#include <asm/hardirq.h>
 #include <linux/netdevice.h>
 #include <linux/in.h>
 #include <linux/list.h>
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
