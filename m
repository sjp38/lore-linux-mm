Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 136C26B00B8
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 07:03:42 -0400 (EDT)
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH v3 1/3] mm: make generic_access_phys available for modules
Date: Wed,  7 Aug 2013 13:02:52 +0200
Message-Id: <1375873374-12601-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Hans J. Koch" <hjk@hansjkoch.de>, linux-kernel@vger.kernel.org, kernel@pengutronix.de, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

In the next commit this function will be used in the uio subsystem

Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
---
Hello,

Greg suggested to take this patch together with the next one via his uio
tree with the appropriate acks.

Best regards
Uwe

 mm/memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index 1ce2e2a..8d9255b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4066,6 +4066,7 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 
 	return len;
 }
+EXPORT_SYMBOL_GPL(generic_access_phys);
 #endif
 
 /*
-- 
1.8.4.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
