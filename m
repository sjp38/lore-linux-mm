From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 08/11] Fix comment about remap_file_pages
Date: Sat, 31 Mar 2007 02:35:51 +0200
Message-ID: <20070331003551.3415.11656.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

This comment is a bit unclear and also stale. So fix it. Thanks to Hugh Dickins
for explaining me what it really referred to, and correcting my first fix.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/fremap.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index f571674..6cb2cc5 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -200,9 +200,10 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 	}
 
 	/*
-	 * We can't clear VM_NONLINEAR because we'd have to do
-	 * it after ->populate completes, and that would prevent
-	 * downgrading the lock.  (Locks can't be upgraded).
+	 * We would like to clear VM_NONLINEAR, in the case when
+	 * sys_remap_file_pages covers the whole vma, so making
+	 * it linear again.  But cannot do so until after a
+	 * successful populate, and have no way to upgrade sem.
 	 */
 
 out:



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
