Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 32CB16B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 06:31:43 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so2033831pad.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 03:31:42 -0800 (PST)
From: Abhijit Pawar <abhi.c.pawar@gmail.com>
Subject: [PATCH RESEND 1/4] mm: remove obsolete simple_strtoul
Date: Mon, 10 Dec 2012 17:00:07 +0530
Message-Id: <1355139007-10012-1-git-send-email-abhi.c.pawar@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>
Cc: Abhijit Pawar <abhi.c.pawar@gmail.com>

This patch replace the obsolete simple_strtoul with kstrtoul API.

Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
---
 mm/kmemleak.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index a217cc5..752a705 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1556,7 +1556,8 @@ static int dump_str_object_info(const char *str)
 	struct kmemleak_object *object;
 	unsigned long addr;
 
-	addr= simple_strtoul(str, NULL, 0);
+	if (kstrtoul(str, 0, &addr))
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
