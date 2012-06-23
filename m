Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id C32096B02AF
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 06:05:42 -0400 (EDT)
From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 11/12] vmalloc: remove KM_USER0 from comments
Date: Sat, 23 Jun 2012 18:04:22 +0800
Message-Id: <1340445863-16111-12-git-send-email-amwang@redhat.com>
In-Reply-To: <1340445863-16111-1-git-send-email-amwang@redhat.com>
References: <1340445863-16111-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, David Rientjes <rientjes@google.com>, Joe Perches <joe@perches.com>, David Vrabel <david.vrabel@citrix.com>, Kautuk Consul <consul.kautuk@gmail.com>, linux-mm@kvack.org

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 mm/vmalloc.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2aad499..c7ac8e1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1975,9 +1975,7 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
  *	IOREMAP area is treated as memory hole and no copy is done.
  *
  *	If [addr...addr+count) doesn't includes any intersects with alive
- *	vm_struct area, returns 0.
- *	@buf should be kernel's buffer. Because	this function uses KM_USER0,
- *	the caller should guarantee KM_USER0 is not used.
+ *	vm_struct area, returns 0. @buf should be kernel's buffer.
  *
  *	Note: In usual ops, vread() is never necessary because the caller
  *	should know vmalloc() area is valid and can use memcpy().
@@ -2051,9 +2049,7 @@ finished:
  *	IOREMAP area is treated as memory hole and no copy is done.
  *
  *	If [addr...addr+count) doesn't includes any intersects with alive
- *	vm_struct area, returns 0.
- *	@buf should be kernel's buffer. Because	this function uses KM_USER0,
- *	the caller should guarantee KM_USER0 is not used.
+ *	vm_struct area, returns 0. @buf should be kernel's buffer.
  *
  *	Note: In usual ops, vwrite() is never necessary because the caller
  *	should know vmalloc() area is valid and can use memcpy().
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
