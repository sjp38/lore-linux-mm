Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 857A16B0074
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 18:50:46 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gq15so46369986lab.12
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:50:46 -0800 (PST)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com. [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id l4si17986482lam.134.2015.02.02.15.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 15:50:45 -0800 (PST)
Received: by mail-la0-f52.google.com with SMTP id ge10so46425312lab.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:50:44 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 4/5] mm/mm_init.c: Mark mminit_loglevel __meminitdata
Date: Tue,  3 Feb 2015 00:50:15 +0100
Message-Id: <1422921016-27618-5-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mminit_loglevel is only referenced from __init and __meminit
functions, so we can mark it __meminitdata.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 mm/mm_init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mm_init.c b/mm/mm_init.c
index e17c758b27bf..5f420f7fafa1 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -14,7 +14,7 @@
 #include "internal.h"
 
 #ifdef CONFIG_DEBUG_MEMORY_INIT
-int mminit_loglevel;
+int __meminitdata mminit_loglevel;
 
 #ifndef SECTIONS_SHIFT
 #define SECTIONS_SHIFT	0
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
