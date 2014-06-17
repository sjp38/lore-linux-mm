Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 667966B0036
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 18:16:05 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id c1so117974igq.10
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 15:16:05 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id m3si510424igx.17.2014.06.17.15.16.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 15:16:05 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id h15so123435igd.2
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 15:16:04 -0700 (PDT)
Date: Tue, 17 Jun 2014 15:16:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, slub: mark resiliency_test as init text
Message-ID: <alpine.DEB.2.02.1406171515390.32660@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

resiliency_test() is only called for bootstrap, so it may be moved to init.text 
and freed after boot.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4207,7 +4207,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 #endif
 
 #ifdef SLUB_RESILIENCY_TEST
-static void resiliency_test(void)
+static void __init resiliency_test(void)
 {
 	u8 *p;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
