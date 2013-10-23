Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EDCFE6B00E0
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 07:33:27 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so1034524pad.21
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 04:33:27 -0700 (PDT)
Received: from psmtp.com ([74.125.245.136])
        by mx.google.com with SMTP id ll9si15179242pab.240.2013.10.23.04.33.26
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 04:33:27 -0700 (PDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH 1/3] memcg, kmem: Use is_root_cache instead of hard code
Date: Wed, 23 Oct 2013 19:31:13 +0800
Message-ID: <1382527875-10112-2-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com>
References: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, glommer@parallels.com, rientjes@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 mm/memcontrol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b73988a..15ad0e3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -57,6 +57,7 @@
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/tcp_memcontrol.h>
+#include "slab.h"
 
 #include <asm/uaccess.h>
 
@@ -3064,7 +3065,7 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 {
 	struct memcg_cache_params *cur_params = s->memcg_params;
 
-	VM_BUG_ON(s->memcg_params && !s->memcg_params->is_root_cache);
+	VM_BUG_ON(!is_root_cache(s));
 
 	if (num_groups > memcg_limited_groups_array_size) {
 		int i;
-- 
1.8.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
