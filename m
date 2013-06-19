Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 2C00B6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:33:59 -0400 (EDT)
Date: Wed, 19 Jun 2013 14:33:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [3.11 3/4] Move kmalloc_node functions to common code
In-Reply-To: <20130619063037.GB12231@lge.com>
Message-ID: <0000013f5cdb37c1-e49e6800-565f-4ff1-b8ca-3a00f75d388d-000000@email.amazonses.com>
References: <20130614195500.373711648@linux.com> <0000013f444bf6e9-d535ba8b-df9e-4053-9ed4-eaba75e2cfd2-000000@email.amazonses.com> <20130619063037.GB12231@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, 19 Jun 2013, Joonsoo Kim wrote:

> > +#ifndef CONFIG_SLOB
> > +	if (__builtin_constant_p(size) &&
> > +		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLAB_CACHE_DMA)) {
>
> s/SLAB_CACHE_DMA/GFP_DMA

Ok. Could you remove the rest of the email in the future? Its difficult to
find your comment in the long diff.


Subject: slab.h: Use the correct GFP flag.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2013-06-18 11:53:29.000000000 -0500
+++ linux/include/linux/slab.h	2013-06-19 09:31:58.303069398 -0500
@@ -421,7 +421,7 @@ static __always_inline void *kmalloc_nod
 {
 #ifndef CONFIG_SLOB
 	if (__builtin_constant_p(size) &&
-		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLAB_CACHE_DMA)) {
+		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
 		int i = kmalloc_index(size);

 		if (!i)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
