Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2FA096B005A
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 16:58:21 -0400 (EDT)
Date: Tue, 21 Aug 2012 20:58:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: C12 [12/19] Move kmem_cache allocations into common code.
In-Reply-To: <50337722.3040908@parallels.com>
Message-ID: <000001394afa9429-b8219750-1ae1-45f2-be1b-e02054615021-000000@email.amazonses.com>
References: <20120820204021.494276880@linux.com> <0000013945cd2d87-d71d0827-51b3-4c98-890f-12beb8ecc72b-000000@email.amazonses.com> <50337722.3040908@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.02.1208211558012.30260@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue, 21 Aug 2012, Glauber Costa wrote:

> Doesn't boot (SLUB + debug options)

Subject: slub: use kmem_cache_zalloc to zero kmalloc cache

Memory for kmem_cache needs to be zeroed in slub after we moved the
allocation into slab_commmon.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-08-21 15:54:42.298087150 -0500
+++ linux/mm/slub.c	2012-08-21 15:55:16.386555367 -0500
@@ -3259,7 +3259,7 @@ static struct kmem_cache *__init create_
 {
 	struct kmem_cache *s;

-	s = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
+	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);

 	/*
 	 * This function is called with IRQs disabled during early-boot on

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
