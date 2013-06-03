Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7FD956B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 11:34:03 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf11so941278pab.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 08:34:02 -0700 (PDT)
Message-ID: <51ACB764.2000808@gmail.com>
Date: Mon, 03 Jun 2013 23:33:56 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] mm, vmalloc: Call setup_vmalloc_vm instead of insert_vmalloc_vm
References: <51ACB6DB.6040809@gmail.com>
In-Reply-To: <51ACB6DB.6040809@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Here we pass flags with only VM_ALLOC bit set, it is unnecessary
to call clear_vm_unlist to clear VM_UNLIST bit. So use setup_vmalloc_vm
instead of insert_vmalloc_vm.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/vmalloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 6580c76..edbfad0 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2503,8 +2503,8 @@ found:
 
 	/* insert all vm's */
 	for (area = 0; area < nr_vms; area++)
-		insert_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
-				  pcpu_get_vm_areas);
+		setup_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
+				 pcpu_get_vm_areas);
 
 	kfree(vas);
 	return vms;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
