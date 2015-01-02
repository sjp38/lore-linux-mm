Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A3A8A6B0038
	for <linux-mm@kvack.org>; Thu,  1 Jan 2015 22:03:34 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so23029674pdj.13
        for <linux-mm@kvack.org>; Thu, 01 Jan 2015 19:03:34 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id x2si20648838pas.236.2015.01.01.19.03.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 Jan 2015 19:03:33 -0800 (PST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so23266213pac.25
        for <linux-mm@kvack.org>; Thu, 01 Jan 2015 19:03:32 -0800 (PST)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] Documentation: mm: Fix typo in vm.txt
Date: Fri,  2 Jan 2015 12:03:19 +0900
Message-Id: <1420167799-9587-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org
Cc: linux-mm@kvack.org, Masanari Iida <standby24x7@gmail.com>

This patch fix a spelling typo in Documentation/sysctl/vm.txt

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/sysctl/vm.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 4415aa9..de3afef 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -728,7 +728,7 @@ The default value is 60.
 
 - user_reserve_kbytes
 
-When overcommit_memory is set to 2, "never overommit" mode, reserve
+When overcommit_memory is set to 2, "never overcommit" mode, reserve
 min(3% of current process size, user_reserve_kbytes) of free memory.
 This is intended to prevent a user from starting a single memory hogging
 process, such that they cannot recover (kill the hog).
-- 
2.2.1.62.g3f15098

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
