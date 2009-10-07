Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 999446B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 02:14:06 -0400 (EDT)
Received: by pxi2 with SMTP id 2so765202pxi.11
        for <linux-mm@kvack.org>; Tue, 06 Oct 2009 23:14:05 -0700 (PDT)
Date: Wed, 7 Oct 2009 14:12:23 +0800
From: Zhenwen Xu <helight.xu@gmail.com>
Subject: [PATCH] fix two warnings on mm/percpu.c
Message-ID: <20091007061223.GA17794@helight>
Reply-To: Zhenwen Xu <helight.xu@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

fix those two warnings:

mm/percpu.c: In function a??pcpu_embed_first_chunka??:
mm/percpu.c:1873: warning: comparison of distinct pointer types lacks a cast
mm/percpu.c:1879: warning: format a??%lxa?? expects type a??long unsigned inta??, but
argument 2 has type a??size_t

Signed-off-by: Zhenwen Xu <helight.xu@gmail.com>
---
 mm/percpu.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 4a048ab..fc0fc6a 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1817,7 +1817,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, ssize_t dyn_size,
 	void *base = (void *)ULONG_MAX;
 	void **areas = NULL;
 	struct pcpu_alloc_info *ai;
-	size_t size_sum, areas_size, max_distance;
+	size_t size_sum, areas_size;
+	unsigned long max_distance;
 	int group, i, rc;
 
 	ai = pcpu_build_alloc_info(reserved_size, dyn_size, atom_size,
-- 
1.6.3.3

-- 
--------------------------------
http://zhwen.org - Open and Free

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
