Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id D3F9D6B0253
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 08:56:52 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id p65so224042293wmp.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:56:52 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id f80si4243004wmi.87.2016.03.31.05.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 05:56:51 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id 20so112716501wmh.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:56:51 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1] mm, kasan: fix compilation for CONFIG_SLAB
Date: Thu, 31 Mar 2016 14:56:45 +0200
Message-Id: <c7df7e8178f8ef3f95164d98f163677b9af2587f.1459428946.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add the missing argument to set_track().

Fixes: cd11016e5f5212c13c0cec7384a525edc93b4921
("mm, kasan: stackdepot implementation. Enable stackdepot for SLAB")
Signed-off-by: Alexander Potapenko <glider@google.com>
---
 mm/kasan/kasan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index acb3b6c..38f1dd7 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -498,7 +498,7 @@ void kasan_slab_free(struct kmem_cache *cache, void *object)
 		struct kasan_alloc_meta *alloc_info =
 			get_alloc_info(cache, object);
 		alloc_info->state = KASAN_STATE_FREE;
-		set_track(&free_info->track);
+		set_track(&free_info->track, GFP_NOWAIT);
 	}
 #endif
 
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
