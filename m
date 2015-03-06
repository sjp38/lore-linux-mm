Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 343906B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 16:52:59 -0500 (EST)
Received: by padet14 with SMTP id et14so58169144pad.0
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 13:52:58 -0800 (PST)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0146.outbound.protection.outlook.com. [157.56.110.146])
        by mx.google.com with ESMTPS id rg12si16763493pdb.99.2015.03.06.13.52.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Mar 2015 13:52:58 -0800 (PST)
From: Yannick Guerrini <yguerrini@tomshardware.fr>
Subject: [PATCH] percpu: Fix trivial typos in comments
Date: Fri, 6 Mar 2015 22:52:28 +0100
Message-ID: <1425678748-11848-1-git-send-email-yguerrini@tomshardware.fr>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: cl@linux-foundation.org, trivial@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yannick Guerrini <yguerrini@tomshardware.fr>

Change 'iff' to 'if'
Change 'tranlated' to 'translated'
Change 'mutliples' to 'multiples'

Signed-off-by: Yannick Guerrini <yguerrini@tomshardware.fr>
---
 mm/percpu.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 73c97a5..6e6dcdb 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -324,7 +324,7 @@ static void pcpu_mem_free(void *ptr, size_t size)
  *
  * Count the number of pages chunk's @i'th area occupies.  When the area's
  * start and/or end address isn't aligned to page boundary, the straddled
- * page is included in the count iff the rest of the page is free.
+ * page is included in the count if the rest of the page is free.
  */
 static int pcpu_count_occupied_pages(struct pcpu_chunk *chunk, int i)
 {
@@ -963,7 +963,7 @@ restart:
 
 	/*
 	 * No space left.  Create a new chunk.  We don't want multiple
-	 * tasks to create chunks simultaneously.  Serialize and create iff
+	 * tasks to create chunks simultaneously.  Serialize and create if
 	 * there's still no empty chunk after grabbing the mutex.
 	 */
 	if (is_atomic)
@@ -1310,7 +1310,7 @@ bool is_kernel_percpu_address(unsigned long addr)
  * and, from the second one, the backing allocator (currently either vm or
  * km) provides translation.
  *
- * The addr can be tranlated simply without checking if it falls into the
+ * The addr can be translated simply without checking if it falls into the
  * first chunk. But the current code reflects better how percpu allocator
  * actually works, and the verification can discover both bugs in percpu
  * allocator itself and per_cpu_ptr_to_phys() callers. So we keep current
@@ -1744,7 +1744,7 @@ early_param("percpu_alloc", percpu_alloc_setup);
 #define BUILD_EMBED_FIRST_CHUNK
 #endif
 
-/* build pcpu_page_first_chunk() iff needed by the arch config */
+/* build pcpu_page_first_chunk() if needed by the arch config */
 #if defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
 #define BUILD_PAGE_FIRST_CHUNK
 #endif
@@ -1762,7 +1762,7 @@ early_param("percpu_alloc", percpu_alloc_setup);
  * and other parameters considering needed percpu size, allocation
  * atom size and distances between CPUs.
  *
- * Groups are always mutliples of atom size and CPUs which are of
+ * Groups are always multiples of atom size and CPUs which are of
  * LOCAL_DISTANCE both ways are grouped together and share space for
  * units in the same group.  The returned configuration is guaranteed
  * to have CPUs on different nodes on different groups and >=75% usage
-- 
1.9.5.msysgit.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
