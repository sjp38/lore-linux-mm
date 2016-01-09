Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 93F036B0256
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 06:30:32 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id x67so389046085ykd.2
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 03:30:32 -0800 (PST)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id m123si7333323ywf.387.2016.01.09.03.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 03:30:31 -0800 (PST)
Received: by mail-yk0-x22b.google.com with SMTP id v14so295206666ykd.3
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 03:30:31 -0800 (PST)
From: nimisolo <nimisolo@gmail.com>
Subject: [PATCH] mm/memblock: If nr_new is 0 just return
Date: Sat,  9 Jan 2016 06:30:23 -0500
Message-Id: <1452339024-3416-1-git-send-email-nimisolo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kuleshovmail@gmail.com, penberg@kernel.org, tony.luck@intel.com, mgorman@suse.de, tangchen@cn.fujitsu.com, weiyang@linux.vnet.ibm.com, holt@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nimisolo <nimisolo@gmail.com>

If nr_new is 0 which means there's no region would be added,
so just return to the caller.

Signed-off-by: nimisolo <nimisolo@gmail.com>
---
 mm/memblock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index d300f13..9a30077 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -588,6 +588,9 @@ repeat:
 					       nid, flags);
 	}
 
+	if (!nr_new)
+		return 0;
+
 	/*
 	 * If this was the first round, resize array and repeat for actual
 	 * insertions; otherwise, merge and return.
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
