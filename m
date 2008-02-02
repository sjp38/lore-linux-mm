Received: by an-out-0708.google.com with SMTP id d33so403257and.105
        for <linux-mm@kvack.org>; Fri, 01 Feb 2008 22:36:54 -0800 (PST)
Message-ID: <28c262360802012236w3a1b4253h2a6ad96570d4a634@mail.gmail.com>
Date: Sat, 2 Feb 2008 15:36:54 +0900
From: "minchan kim" <minchan.kim@gmail.com>
Subject: [PATCH] modify incorrected word in comment of clear_active_flags
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I think is was a mistake.
clear_active_flags is just called by shrink_inactive_list.

--- mm/vmscan.c.orig  2008-02-02 15:21:52.000000000 +0900
+++ mm/vmscan.c 2008-02-02 15:20:46.000000000 +0900
@@ -761,7 +761,7 @@ static unsigned long isolate_lru_pages(u
 }

 /*
- * clear_active_flags() is a helper for shrink_active_list(), clearing
+ * clear_active_flags() is a helper for shrink_inactive_list(), clearing
  * any active bits from the pages in the list.
  */
 static unsigned long clear_active_flags(struct list_head *page_list)



-- 
Kinds regards,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
