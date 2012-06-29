Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 71F9A6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 07:06:32 -0400 (EDT)
Message-ID: <4FED8C1A.5020301@oracle.com>
Date: Fri, 29 Jun 2012 19:06:02 +0800
From: Jeff Liu <jeff.liu@oracle.com>
Reply-To: jeff.liu@oracle.com
MIME-Version: 1.0
Subject: [PATCH RESEND] mm/memory.c: print_vma_addr() call up_read(&mm->mmap_sem)
 directly
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

Call up_read(&mm->mmap_sem) directly since we have already got mm
via current->mm at the beginning of print_vma_addr().

Thanks,
-Jeff


Signed-off-by: Jie Liu <jeff.liu@oracle.com>

---
 mm/memory.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 2466d12..6e49113 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3929,7 +3929,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 			free_page((unsigned long)buf);
 		}
 	}
-	up_read(&current->mm->mmap_sem);
+	up_read(&mm->mmap_sem);
 }

 #ifdef CONFIG_PROVE_LOCKING
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
