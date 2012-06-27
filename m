Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 2ACF56B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:09:25 -0400 (EDT)
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by rcsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q5R59NEN022333
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 05:09:24 GMT
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by ucsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q5R59MZH012939
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 05:09:23 GMT
Received: from abhmt110.oracle.com (abhmt110.oracle.com [141.146.116.62])
	by acsmt356.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q5R59MUd030515
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 00:09:22 -0500
Message-ID: <4FEA9568.4030902@oracle.com>
Date: Wed, 27 Jun 2012 13:08:56 +0800
From: Jeff Liu <jeff.liu@oracle.com>
Reply-To: jeff.liu@oracle.com
MIME-Version: 1.0
Subject: [PATCH] mm/memory.c:  print_vma_addr()  call up_read(&mm->mmap_sem)
 directly
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello,

We can call up_read(&mm->mmap_sem) directly since we have already got mm
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
