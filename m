Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB646B0072
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:51 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so13147620iec.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id rv2si3027418igb.34.2015.04.14.13.56.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Apr 2015 13:56:43 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 06/11] mm: debug: clean unused code
Date: Tue, 14 Apr 2015 16:56:28 -0400
Message-Id: <1429044993-1677-7-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

Remove dump_flags which is no longer used.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/debug.c |   30 ------------------------------
 1 file changed, 30 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index f64bb6e..13f2555 100644
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
