Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id D8B2382F65
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 16:03:44 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so5166070wic.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:03:44 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id lr4si6999196wic.99.2015.10.16.13.03.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 13:03:43 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] memcg: include linux/mm.h
Date: Fri, 16 Oct 2015 22:03:31 +0200
Message-ID: <14714191.7FdLxZ8X79@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

A recent change to the memcg code added a call to virt_to_head_page,
which is declared in linux/mm.h, but this is not necessarily included
here and will cause compile errors:

include/linux/memcontrol.h:841:9: error: implicit declaration of function 'virt_to_head_page' [-Werror=implicit-function-declaration]

This adds an explicit include statement that gets rid of the error.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 1ead4c071978 ("memcg: simplify and inline __mem_cgroup_from_kmem")

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 47677acb4516..6d18936df7e8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -27,6 +27,7 @@
 #include <linux/vmpressure.h>
 #include <linux/eventfd.h>
 #include <linux/mmzone.h>
+#include <linux/mm.h>
 #include <linux/writeback.h>
 
 struct mem_cgroup;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
