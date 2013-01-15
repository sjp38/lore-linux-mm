Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id C97E46B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 02:36:01 -0500 (EST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] tools, vm: add .gitignore to ignore built binaries
Date: Tue, 15 Jan 2013 16:35:57 +0900
Message-Id: <1358235357-6126-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, js1304@gmail.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is no .gitignore in tools/vm,
so 'git status' always show built binaries.
To ignore this, add .gitignore.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/tools/vm/.gitignore b/tools/vm/.gitignore
new file mode 100644
index 0000000..44f095f
--- /dev/null
+++ b/tools/vm/.gitignore
@@ -0,0 +1,2 @@
+slabinfo
+page-types
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
