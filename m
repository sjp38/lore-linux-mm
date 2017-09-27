Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 369D06B0260
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 20:54:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m30so24098968pgn.2
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 17:54:28 -0700 (PDT)
Received: from out0-206.mail.aliyun.com (out0-206.mail.aliyun.com. [140.205.0.206])
        by mx.google.com with ESMTPS id w12si6600941pgo.419.2017.09.26.17.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 17:54:27 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 3/3] doc: add description for unreclaim_slabs_oom_ratio
Date: Wed, 27 Sep 2017 08:53:36 +0800
Message-Id: <1506473616-88120-4-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add the description for unreclaim_slabs_oom_ratio in
Documentation/sysctl/vm.txt.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 Documentation/sysctl/vm.txt | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a..29926e3 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -59,6 +59,7 @@ Currently, these files are in /proc/sys/vm:
 - stat_interval
 - stat_refresh
 - swappiness
+- unreclaim_slabs_oom_ratio
 - user_reserve_kbytes
 - vfs_cache_pressure
 - watermark_scale_factor
@@ -804,6 +805,17 @@ The default value is 60.
 
 ==============================================================
 
+unreclaim_slabs_oom_ratio
+
+The percentage of total unreclaimable slabs amount vs all user memory amount
+(LRU pages). When the real ratio is greater than the value, oom killer would
+dump unreclaimable slabs info when kernel panic.
+The range is 0 - 100. 0 means dump unreclaimable slabs info unconditionally.
+
+The default value is 50.
+
+==============================================================
+
 - user_reserve_kbytes
 
 When overcommit_memory is set to 2, "never overcommit" mode, reserve
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
