Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id CCCA96B0074
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:10:42 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so91960304pac.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:10:42 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id za1si25127806pbb.154.2015.05.14.10.10.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:10:38 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 06/11] mm: debug: clean unused code
Date: Thu, 14 May 2015 13:10:09 -0400
Message-Id: <1431623414-1905-7-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name, Sasha Levin <sasha.levin@oracle.com>

Remove dump_flags which is no longer used.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/debug.c |   30 ------------------------------
 1 file changed, 30 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 44efbb5..3abea22 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -50,36 +50,6 @@ static const struct trace_print_flags pageflag_names[] = {
 #endif
 };
 
-static void dump_flags(unsigned long flags,
-			const struct trace_print_flags *names, int count)
-{
-	const char *delim = "";
-	unsigned long mask;
-	int i;
-
-	pr_emerg("flags: %#lx(", flags);
-
-	/* remove zone id */
-	flags &= (1UL << NR_PAGEFLAGS) - 1;
-
-	for (i = 0; i < count && flags; i++) {
-
-		mask = names[i].mask;
-		if ((flags & mask) != mask)
-			continue;
-
-		flags &= ~mask;
-		pr_cont("%s%s", delim, names[i].name);
-		delim = "|";
-	}
-
-	/* check for left over flags */
-	if (flags)
-		pr_cont("%s%#lx", delim, flags);
-
-	pr_cont(")\n");
-}
-
 static char *format_flags(unsigned long flags,
 			const struct trace_print_flags *names, int count,
 			char *buf, char *end)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
