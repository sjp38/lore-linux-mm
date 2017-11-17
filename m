Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C65DB6B027B
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:04:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 27so3478019pft.8
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 15:04:13 -0800 (PST)
Received: from out0-205.mail.aliyun.com (out0-205.mail.aliyun.com. [140.205.0.205])
        by mx.google.com with ESMTPS id h9si3551006pls.588.2017.11.17.15.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 15:04:12 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 6/8] net: caif: remove unused hardirq.h
Date: Sat, 18 Nov 2017 07:02:19 +0800
Message-Id: <1510959741-31109-6-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Yang Shi <yang.s@alibaba-inc.com>, Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>, "David S. Miller" <davem@davemloft.net>

Preempt counter APIs have been split out, currently, hardirq.h just
includes irq_enter/exit APIs which are not used by caif at all.

So, remove the unused hardirq.h.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/caif/cfpkt_skbuff.c | 1 -
 net/caif/chnl_net.c     | 1 -
 2 files changed, 2 deletions(-)

diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 71b6ab2..38c2b7a 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -8,7 +8,6 @@
 
 #include <linux/string.h>
 #include <linux/skbuff.h>
-#include <linux/hardirq.h>
 #include <linux/export.h>
 #include <net/caif/cfpkt.h>
 
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 922ac1d..53ecda1 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -8,7 +8,6 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
 
 #include <linux/fs.h>
-#include <linux/hardirq.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
