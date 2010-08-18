Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B0A866B01FA
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 13:06:21 -0400 (EDT)
Date: Wed, 18 Aug 2010 12:06:17 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup2 6/6] slub: Move gfpflag masking out of the
 hotpath
In-Reply-To: <20100818162639.402753062@linux.com>
Message-ID: <alpine.DEB.2.00.1008181205260.7416@router.home>
References: <20100818162539.281413425@linux.com> <20100818162639.402753062@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>


Subject: Missing hunk

The following hung was missing from the patch

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-18 12:04:48.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-18 12:04:40.000000000 -0500
@@ -1729,8 +1729,6 @@ static __always_inline void *slab_alloc(
 	struct kmem_cache_cpu *c;
 	unsigned long flags;

-	gfpflags &= gfp_allowed_mask;
-
 	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
