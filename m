Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 505F26B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 04:26:01 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id 19so60849fgg.4
        for <linux-mm@kvack.org>; Tue, 17 Mar 2009 01:25:59 -0700 (PDT)
Date: Tue, 17 Mar 2009 11:25:49 +0300
From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH next] slob: fix build problem
Message-ID: <20090317082549.GA5127@orion>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
List-ID: <linux-mm.kvack.org>

mm/slob.c: In function '__kmalloc_node':
mm/slob.c:480: error: 'flags' undeclared (first use in this function)

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 mm/slob.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 081cf1e..e49b258 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -477,7 +477,7 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 	void *ret;
 
-	lockdep_trace_alloc(flags);
+	lockdep_trace_alloc(gfp);
 
 	if (size < PAGE_SIZE - align) {
 		if (!size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
