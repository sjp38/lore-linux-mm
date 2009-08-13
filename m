Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 42D9C6B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 02:09:02 -0400 (EDT)
Date: Thu, 13 Aug 2009 02:00:13 -0400
From: Amerigo Wang <amwang@redhat.com>
Message-Id: <20090813060235.5516.12662.sendpatchset@localhost.localdomain>
Subject: [Patch] percpu: use the right flag for get_vm_area()
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, mingo@elte.hu, Amerigo Wang <amwang@redhat.com>
List-ID: <linux-mm.kvack.org>


get_vm_area() only accepts VM_* flags, not GFP_*.

And according to the doc of get_vm_area(), here should be
VM_ALLOC.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>

---
diff --git a/mm/percpu.c b/mm/percpu.c
index b70f2ac..3ef18c7 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -749,7 +749,7 @@ static struct pcpu_chunk *alloc_pcpu_chunk(void)
 	chunk->map[chunk->map_used++] = pcpu_unit_size;
 	chunk->page = chunk->page_ar;
 
-	chunk->vm = get_vm_area(pcpu_chunk_size, GFP_KERNEL);
+	chunk->vm = get_vm_area(pcpu_chunk_size, VM_ALLOC);
 	if (!chunk->vm) {
 		free_pcpu_chunk(chunk);
 		return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
