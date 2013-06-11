Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 2B5656B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 03:14:14 -0400 (EDT)
Date: Tue, 11 Jun 2013 10:13:59 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -mm] UBIFS: signedness bug in ubifs_shrink_count()
Message-ID: <20130611071359.GA6071@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org

We test "clean_zn_cnt" for negative later in the function.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This was introduced in the -mm branch in:
fs-convert-fs-shrinkers-to-new-scan-count-api-fix

diff --git a/fs/ubifs/shrinker.c b/fs/ubifs/shrinker.c
index 68ce399..f35135e 100644
--- a/fs/ubifs/shrinker.c
+++ b/fs/ubifs/shrinker.c
@@ -280,7 +280,7 @@ static int kick_a_thread(void)
 unsigned long ubifs_shrink_count(struct shrinker *shrink,
 				 struct shrink_control *sc)
 {
-	unsigned long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
+	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
 
 	/*
 	 * Due to the way UBIFS updates the clean znode counter it may

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
