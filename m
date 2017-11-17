Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 32F156B027B
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:03:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id k190so3880509pga.10
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 15:03:49 -0800 (PST)
Received: from out0-223.mail.aliyun.com (out0-223.mail.aliyun.com. [140.205.0.223])
        by mx.google.com with ESMTPS id h69si3436033pgc.301.2017.11.17.15.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 15:03:48 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 3/8] fs: btrfs: remove unused hardirq.h
Date: Sat, 18 Nov 2017 07:02:16 +0800
Message-Id: <1510959741-31109-3-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Yang Shi <yang.s@alibaba-inc.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

Preempt counter APIs have been split out, currently, hardirq.h just
includes irq_enter/exit APIs which are not used by btrfs at all.

So, remove the unused hardirq.h.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
---
 fs/btrfs/extent_map.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/btrfs/extent_map.c b/fs/btrfs/extent_map.c
index 2e348fb..cced7f1 100644
--- a/fs/btrfs/extent_map.c
+++ b/fs/btrfs/extent_map.c
@@ -2,7 +2,6 @@
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
-#include <linux/hardirq.h>
 #include "ctree.h"
 #include "extent_map.h"
 #include "compression.h"
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
