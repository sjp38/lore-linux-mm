Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Peng Wang <rocking@whu.edu.cn>
Subject: [PATCH] mm/slub.c: keep red_left_pad being zero without SLAB_RED_ZONE flag
Date: Fri,  4 Jan 2019 18:09:41 +0800
Message-Id: <20190104100941.29872-1-rocking@whu.edu.cn>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peng Wang <rocking@whu.edu.cn>
List-ID: <linux-mm.kvack.org>

It seems more clear for red_left_pad to be zero despite not being used
without SLAB_RED_ZONE flag.

Signed-off-by: Peng Wang <rocking@whu.edu.cn>
---
 mm/slub.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slub.c b/mm/slub.c
index 36c0befeebd8..9d16ca30bc2a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3603,6 +3603,7 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 		if (get_order(s->size) > get_order(s->object_size)) {
 			s->flags &= ~DEBUG_METADATA_FLAGS;
 			s->offset = 0;
+			s->red_left_pad = 0;
 			if (!calculate_sizes(s, -1))
 				goto error;
 		}
-- 
2.19.1
