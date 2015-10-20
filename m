From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: [PATCH] mm: initialize kmem_cache pointer to NULL
Date: Tue, 20 Oct 2015 22:04:11 +0000
Message-ID: <20151020220411.GA19775@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: cl@linux.com
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

The assignment to NULL within the error condition was written
in a 2014 patch to suppress a compiler warning.
However it would be cleaner to just initialize the kmem_cache
to NULL and just return it in case of an error condition.

Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
---
 mm/slab_common.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 5ce4fae..cf0b7bb 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -384,7 +384,7 @@ struct kmem_cache *
 kmem_cache_create(const char *name, size_t size, size_t align,
 		  unsigned long flags, void (*ctor)(void *))
 {
-	struct kmem_cache *s;
+	struct kmem_cache *s = NULL;
 	const char *cache_name;
 	int err;
 
@@ -396,7 +396,6 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	err = kmem_cache_sanity_check(name, size);
 	if (err) {
-		s = NULL;	/* suppress uninit var warning */
 		goto out_unlock;
 	}
 
-- 
2.6.1
