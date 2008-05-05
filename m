Received: by wf-out-1314.google.com with SMTP id 28so2959503wfc.11
        for <linux-mm@kvack.org>; Mon, 05 May 2008 10:05:43 -0700 (PDT)
From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] mm/pdflush.c: merge the same code in two path
Date: Tue,  6 May 2008 01:05:09 +0800
Message-Id: <1210007109-15998-1-git-send-email-crquan@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Denis <cr_quan@163.com>
List-ID: <linux-mm.kvack.org>

---
 mm/pdflush.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/pdflush.c b/mm/pdflush.c
index 1c96cfc..9d834aa 100644
--- a/mm/pdflush.c
+++ b/mm/pdflush.c
@@ -207,7 +207,6 @@ int pdflush_operation(void (*fn)(unsigned long), unsigned long arg0)
 
 	spin_lock_irqsave(&pdflush_lock, flags);
 	if (list_empty(&pdflush_list)) {
-		spin_unlock_irqrestore(&pdflush_lock, flags);
 		ret = -1;
 	} else {
 		struct pdflush_work *pdf;
@@ -219,8 +218,9 @@ int pdflush_operation(void (*fn)(unsigned long), unsigned long arg0)
 		pdf->fn = fn;
 		pdf->arg0 = arg0;
 		wake_up_process(pdf->who);
-		spin_unlock_irqrestore(&pdflush_lock, flags);
 	}
+	spin_unlock_irqrestore(&pdflush_lock, flags);
+
 	return ret;
 }
 
-- 
1.5.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
