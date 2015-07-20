Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 561EA28024F
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:55:39 -0400 (EDT)
Received: by qged69 with SMTP id d69so44306259qge.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:55:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o21si24524279qko.23.2015.07.20.07.55.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 07:55:38 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH 1/3] percpu: clean up of schunk->map[] assignment in pcpu_setup_first_chunk
Date: Mon, 20 Jul 2015 22:55:28 +0800
Message-Id: <1437404130-5188-1-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Baoquan He <bhe@redhat.com>

The original assignment is a little redundent.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/percpu.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 2dd7448..a63b4d8 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1668,9 +1668,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	schunk->map[1] = ai->static_size;
 	schunk->map_used = 1;
 	if (schunk->free_size)
-		schunk->map[++schunk->map_used] = 1 | (ai->static_size + schunk->free_size);
-	else
-		schunk->map[1] |= 1;
+		schunk->map[++schunk->map_used] = ai->static_size + schunk->free_size;
+	schunk->map[schunk->map_used] |= 1;
 
 	/* init dynamic chunk if necessary */
 	if (dyn_size) {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
