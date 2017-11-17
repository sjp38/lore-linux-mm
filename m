Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 783576B027B
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:04:21 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q126so3890329pgq.7
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 15:04:21 -0800 (PST)
Received: from out0-242.mail.aliyun.com (out0-242.mail.aliyun.com. [140.205.0.242])
        by mx.google.com with ESMTPS id h7si3423112pgq.512.2017.11.17.15.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 15:04:20 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 7/8] net: ovs: remove unused hardirq.h
Date: Sat, 18 Nov 2017 07:02:20 +0800
Message-Id: <1510959741-31109-7-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Yang Shi <yang.s@alibaba-inc.com>, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>, dev@openvswitch.org

Preempt counter APIs have been split out, currently, hardirq.h just
includes irq_enter/exit APIs which are not used by openvswitch at all.

So, remove the unused hardirq.h.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Cc: Pravin Shelar <pshelar@nicira.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: dev@openvswitch.org
---
 net/openvswitch/vport-internal_dev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 04a3128..2f47c65 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -16,7 +16,6 @@
  * 02110-1301, USA
  */
 
-#include <linux/hardirq.h>
 #include <linux/if_vlan.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
