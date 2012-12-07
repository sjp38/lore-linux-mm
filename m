Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 1E5A66B0081
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 06:37:52 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so331495pbc.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 03:37:51 -0800 (PST)
From: Abhijit Pawar <abhi.c.pawar@gmail.com>
Subject: [PATCH 1/4] mm: remove obsolete simple_strtoul
Date: Fri,  7 Dec 2012 17:07:17 +0530
Message-Id: <1354880237-23107-1-git-send-email-abhi.c.pawar@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Abhijit Pawar <abhi.c.pawar@gmail.com>

This patch replace the obsolete simple_strtoul with kstrtoul API.

Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
---
 mm/kmemleak.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index a217cc5..b141532 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1555,8 +1555,11 @@ static int dump_str_object_info(const char *str)
 	unsigned long flags;
 	struct kmemleak_object *object;
 	unsigned long addr;
+	int rc;
 
-	addr= simple_strtoul(str, NULL, 0);
+	rc = kstrtoul(str, 0, &addr);
+	if (rc)
+		return -EINVAL;
 	object = find_and_get_object(addr, 0);
 	if (!object) {
 		pr_info("Unknown object at 0x%08lx\n", addr);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
