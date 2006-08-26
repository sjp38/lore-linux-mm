From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH RFP-V4 05/13] RFP prot support: disallow mprotect() on manyprots mappings
Date: Sat, 26 Aug 2006 19:42:24 +0200
Message-Id: <20060826174224.14790.16609.stgit@memento.home.lan>
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

For now we (I and Hugh) have found no agreement on which behavior to implement
here. So, at least as a stop-gap, return an error here.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/mprotect.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 638edab..401ae11 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -240,6 +240,13 @@ sys_mprotect(unsigned long start, size_t
 	error = -ENOMEM;
 	if (!vma)
 		goto out;
+
+	/* If a need is felt, an appropriate behaviour may be implemented for
+	 * this case. We haven't agreed yet on which behavior is appropriate. */
+	error = -EACCES;
+	if (vma->vm_flags & VM_MANYPROTS)
+		goto out;
+
 	if (unlikely(grows & PROT_GROWSDOWN)) {
 		if (vma->vm_start >= end)
 			goto out;
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
