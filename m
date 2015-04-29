Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CC5B86B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 12:00:43 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so31599409pab.3
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:00:43 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ca1si24243937pbb.169.2015.04.29.09.00.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 09:00:43 -0700 (PDT)
Received: by pacwv17 with SMTP id wv17so31737022pac.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:00:42 -0700 (PDT)
From: Shawn Chang <citypw@gmail.com>
Subject: [PATCH 2/2] Fix variable "error" missing initialization
Date: Thu, 30 Apr 2015 00:00:34 +0800
Message-Id: <1430323234-17452-1-git-send-email-citypw@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Shawn C <citypw@gmail.com>

From: Shawn C <citypw@gmail.com>

Signed-off-by: Shawn C <citypw@gmail.com>
---
 mm/mlock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index c7f6785..660e5c5 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -557,7 +557,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 {
 	unsigned long nstart, end, tmp;
 	struct vm_area_struct * vma, * prev;
-	int error;
+	int error = 0;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(len != PAGE_ALIGN(len));
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
