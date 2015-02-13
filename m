Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7116B007B
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 11:38:31 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id w62so17659974wes.12
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 08:38:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h7si4641086wiz.75.2015.02.13.08.38.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Feb 2015 08:38:29 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: update copyright notice
Date: Fri, 13 Feb 2015 11:38:27 -0500
Message-Id: <1423845507-14844-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Add myself to the list of copyright holders.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef1b0be6f8e1..54b740faf7c6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -14,6 +14,12 @@
  * Copyright (C) 2012 Parallels Inc. and Google Inc.
  * Authors: Glauber Costa and Suleiman Souhlal
  *
+ * Native page reclaim
+ * Charge lifetime sanitation
+ * Lockless page tracking & accounting
+ * Unified hierarchy configuration model
+ * Copyright (C) 2015 Red Hat, Inc., Johannes Weiner
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
