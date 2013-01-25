Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 84F936B0002
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 03:17:21 -0500 (EST)
Message-ID: <51023F89.9030807@oracle.com>
Date: Fri, 25 Jan 2013 16:17:13 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] kernel/res_counter.c: move BUG() to the default choice of
 switch at res_counter_member()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

It's quite obvious that the return statement after BUG() is invalid, we had better
move BUG() to the default choice of the switch.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
---
 kernel/res_counter.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index ff55247..748a3bc 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -135,10 +135,9 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->failcnt;
 	case RES_SOFT_LIMIT:
 		return &counter->soft_limit;
+	default:
+		BUG();
 	};
-
-	BUG();
-	return NULL;
 }
 
 ssize_t res_counter_read(struct res_counter *counter, int member,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
