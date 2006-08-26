From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH RFP-V4 02/13] Fix comment about remap_file_pages
Date: Sat, 26 Aug 2006 19:42:13 +0200
Message-Id: <20060826174213.14790.50608.stgit@memento.home.lan>
In-Reply-To: <200608261933.36574.blaisorblade@yahoo.it>
References: <200608261933.36574.blaisorblade@yahoo.it>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This comment is a bit unclear and also stale. So fix it. Thanks to Hugh Dickins
for explaining me what it really referred to, and correcting my first fix.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/fremap.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index 21b7d0c..cdeabad 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -215,9 +215,10 @@ #endif
 					    pgoff, flags & MAP_NONBLOCK);
 
 		/*
-		 * We can't clear VM_NONLINEAR because we'd have to do
-		 * it after ->populate completes, and that would prevent
-		 * downgrading the lock.  (Locks can't be upgraded).
+		 * We would like to clear VM_NONLINEAR, in the case when
+		 * sys_remap_file_pages covers the whole vma, so making
+		 * it linear again.  But cannot do so until after a
+		 * successful populate, and have no way to upgrade sem.
 		 */
 	}
 	if (likely(!has_write_lock))
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
