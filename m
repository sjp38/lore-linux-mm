Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id E69486B0071
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:28:34 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so22767325qkb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:28:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 107si4476493qgy.110.2015.06.17.07.28.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 07:28:34 -0700 (PDT)
Subject: [PATCH V2 1/6] slub: fix spelling succedd to succeed
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 17 Jun 2015 16:27:32 +0200
Message-ID: <20150617142704.11791.40866.stgit@devil>
In-Reply-To: <20150617142613.11791.76008.stgit@devil>
References: <20150617142613.11791.76008.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 54c0876b43d5..41624ccabc63 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2712,7 +2712,7 @@ redo:
 	 * Determine the currently cpus per cpu slab.
 	 * The cpu may change afterward. However that does not matter since
 	 * data is retrieved via this pointer. If we are on the same cpu
-	 * during the cmpxchg then the free will succedd.
+	 * during the cmpxchg then the free will succeed.
 	 */
 	do {
 		tid = this_cpu_read(s->cpu_slab->tid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
