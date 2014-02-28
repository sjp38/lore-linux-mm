Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id EBF2F6B0070
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 17:19:23 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id rq2so1319925pbb.5
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 14:19:23 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id ha5si3508924pbc.30.2014.02.28.14.19.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 14:19:23 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id y10so1298522pdj.39
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 14:19:22 -0800 (PST)
From: Ning Qu <quning@google.com>
Subject: [PATCH 1/1] mm: implement ->map_pages for shmem/tmpfs
Date: Fri, 28 Feb 2014 14:18:51 -0800
Message-Id: <1393625931-2858-2-git-send-email-quning@google.com>
In-Reply-To: <1393625931-2858-1-git-send-email-quning@google.com>
References: <1393625931-2858-1-git-send-email-quning@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

In shmem/tmpfs, we also use the generic filemap_map_pages,
seems the additional checking is not worth a separate version
of map_pages for it.

Signed-off-by: Ning Qu <quning@google.com>
---
 mm/shmem.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 1f18c9d..2ea4e89 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2783,6 +2783,7 @@ static const struct super_operations shmem_ops = {
 
 static const struct vm_operations_struct shmem_vm_ops = {
 	.fault		= shmem_fault,
+	.map_pages	= filemap_map_pages,
 #ifdef CONFIG_NUMA
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
-- 
1.9.0.279.gdc9e3eb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
