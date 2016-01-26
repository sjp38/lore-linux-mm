Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC316B0257
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:56:39 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id u188so123189285wmu.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:56:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i15si7737483wmd.87.2016.01.26.12.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 12:56:38 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] Documentation: cgroup-v2: add memory.stat::sock description
Date: Tue, 26 Jan 2016 15:55:55 -0500
Message-Id: <1453841755-29165-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroup-v2.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 65b3eac8856c..e8d25e784214 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -843,6 +843,10 @@ PAGE_SIZE multiple when read back.
 		Amount of memory used to cache filesystem data,
 		including tmpfs and shared memory.
 
+	  sock
+
+		Amount of memory used in network transmission buffers
+
 	  file_mapped
 
 		Amount of cached filesystem data mapped with mmap()
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
