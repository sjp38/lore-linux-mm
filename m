Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1407F6B003D
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 21:29:59 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so125271pde.6
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 18:29:58 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id gn5si343489pbb.200.2014.06.17.18.29.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 18:29:55 -0700 (PDT)
Message-ID: <53A0EB84.7030308@oracle.com>
Date: Wed, 18 Jun 2014 09:29:40 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH RESEND] slub: return correct error on slab_sysfs_init
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

From: Jie Liu <jeff.liu@oracle.com>

Return -ENOMEM than -ENOSYS if kset_create_and_add() failed

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index b2b0473..e10f60f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5301,7 +5301,7 @@ static int __init slab_sysfs_init(void)
 	if (!slab_kset) {
 		mutex_unlock(&slab_mutex);
 		pr_err("Cannot register slab subsystem.\n");
-		return -ENOSYS;
+		return -ENOMEM;
 	}
 
 	slab_state = FULL;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
