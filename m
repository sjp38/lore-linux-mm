Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 654188D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 17:09:50 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 34/39] mm: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:51 -0700
Message-Id: <01d3ac1297677b782018d82a25e2ca82f7d1ca09.1288471898.git.joe@perches.com>
In-Reply-To: <cover.1288471897.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Kosina <trivial@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Coalesce long formats.
Align arguments.
Remove KERN_<level>.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/percpu.c  |    4 ++--
 mm/vmalloc.c |    5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index efe8168..0aef392 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -715,8 +715,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 	unsigned long flags;
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
-		WARN(true, "illegal size (%zu) or align (%zu) for "
-		     "percpu allocation\n", size, align);
+		WARN(true, "illegal size (%zu) or align (%zu) for percpu allocation\n",
+		     size, align);
 		return NULL;
 	}
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a3d66b3..bf71c20 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1371,14 +1371,13 @@ static void __vunmap(const void *addr, int deallocate_pages)
 		return;
 
 	if ((PAGE_SIZE-1) & (unsigned long)addr) {
-		WARN(1, KERN_ERR "Trying to vfree() bad address (%p)\n", addr);
+		WARN(1, "Trying to vfree() bad address (%p)\n", addr);
 		return;
 	}
 
 	area = remove_vm_area(addr);
 	if (unlikely(!area)) {
-		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
-				addr);
+		WARN(1, "Trying to vfree() nonexistent vm area (%p)\n", addr);
 		return;
 	}
 
-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
