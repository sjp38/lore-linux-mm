Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id A0F256B00A7
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 10:06:15 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id e131so6715844oig.38
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 07:06:15 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id u7si9249277oes.5.2014.11.24.07.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 07:06:14 -0800 (PST)
Received: by mail-ob0-f177.google.com with SMTP id va2so6996182obc.36
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 07:06:14 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 24 Nov 2014 23:06:14 +0800
Message-ID: <CAHkaATSEn9WMKJNRp5QvzPsno_vddtMXY39yvi=BGtb4M+Hqdw@mail.gmail.com>
Subject: [PATCH] slub: fix confusing error messages in check_slab
From: Min-Hua Chen <orca.chen@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

In check_slab, s->name is passed incorrectly to the error
messages. It will cause confusing error messages if the object
check fails. This patch fix this bug by removing s->name.

Signed-off-by: Min-Hua Chen <orca.chen@gmail.com>
---
 mm/slub.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ae7b9f1..5da9f9f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -849,12 +849,12 @@ static int check_slab(struct kmem_cache *s,
struct page *page)
     maxobj = order_objects(compound_order(page), s->size, s->reserved);
     if (page->objects > maxobj) {
         slab_err(s, page, "objects %u > max %u",
-            s->name, page->objects, maxobj);
+             page->objects, maxobj);
         return 0;
     }
     if (page->inuse > page->objects) {
         slab_err(s, page, "inuse %u > max %u",
-            s->name, page->inuse, page->objects);
+             page->inuse, page->objects);
         return 0;
     }
     /* Slab_pad_check fixes things up after itself */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
