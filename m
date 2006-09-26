Received: from  ([::ffff:212.65.3.74] HELO siso-eb-i34d.silicon-software.de) (auth=eike-kernel@sf-tec.de)
	by mail.sf-mail.de (Qsmtpd 0.9) with (DHE-RSA-AES256-SHA encrypted) ESMTPSA
	for <linux-mm@kvack.org>; Tue, 26 Sep 2006 11:43:11 +0200
From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: [PATCH] Mark __remove_vm_area() static
Date: Tue, 26 Sep 2006 11:43:50 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609261143.51105.eike-kernel@sf-tec.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

The function is exported but not used from anywhere else. It's also marked as
"not for driver use" so noone out there should really care.

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>

---
commit 1d88bdc56807cccf598d8b92fb98ddf03f3a42db
tree 72c6525b019b9102c14778141ed1f236d7ebe331
parent 8322f0cb8a117fe42e993d48f5ae0fbc006f8ef0
author Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 26 Sep 2006 11:41:42 +0200
committer Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 26 Sep 2006 11:41:42 +0200

 include/linux/vmalloc.h |    1 -
 mm/vmalloc.c            |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 71b6363..dc6f55e 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -64,7 +64,6 @@ extern struct vm_struct *__get_vm_area(u
 extern struct vm_struct *get_vm_area_node(unsigned long size,
 					unsigned long flags, int node);
 extern struct vm_struct *remove_vm_area(void *addr);
-extern struct vm_struct *__remove_vm_area(void *addr);
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page ***pages);
 extern void unmap_vm_area(struct vm_struct *area);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3ac7c03..44fb4ca 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -269,7 +269,7 @@ static struct vm_struct *__find_vm_area(
 }
 
 /* Caller must hold vmlist_lock */
-struct vm_struct *__remove_vm_area(void *addr)
+static struct vm_struct *__remove_vm_area(void *addr)
 {
 	struct vm_struct **p, *tmp;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
