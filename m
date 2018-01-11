Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8F06B026F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 08:28:45 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 8so2090543pfv.12
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 05:28:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v8sor3104226pfe.30.2018.01.11.05.28.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 05:28:44 -0800 (PST)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] linux-next: DOC: HWPOISON: Fix path to debugfs in hwpoison.txt
Date: Thu, 11 Jan 2018 22:28:37 +0900
Message-Id: <20180111132837.9914-1-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, corbet@lwn.net, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com
Cc: Masanari Iida <standby24x7@gmail.com>

This patch fixes an incorrect path for debugfs in hwpoison.txt

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/vm/hwpoison.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/vm/hwpoison.txt b/Documentation/vm/hwpoison.txt
index 6ae89a9edf2a..e912d7eee769 100644
--- a/Documentation/vm/hwpoison.txt
+++ b/Documentation/vm/hwpoison.txt
@@ -104,7 +104,7 @@ madvise(MADV_HWPOISON, ....)
 
 hwpoison-inject module through debugfs
 
-/sys/debug/hwpoison/
+/sys/kernel/debug/hwpoison/
 
 corrupt-pfn
 
-- 
2.15.1.433.g936d1b989416

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
