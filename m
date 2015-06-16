Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5886B0032
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 17:44:43 -0400 (EDT)
Received: by pacgb13 with SMTP id gb13so20459020pac.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 14:44:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qq9si3053154pbb.13.2015.06.16.14.44.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 14:44:42 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:44:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/7] slab: infrastructure for bulk object allocation and
 freeing
Message-Id: <20150616144441.65bead5677fc13f86b5244f2@linux-foundation.org>
In-Reply-To: <20150615155156.18824.35187.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155156.18824.35187.stgit@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>

On Mon, 15 Jun 2015 17:51:56 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> +bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> +								void **p)
> +{
> +	return kmem_cache_alloc_bulk(s, flags, size, p);
> +}

hm, any call to this function is going to be nasty, brutal and short.

--- a/mm/slab.c~slab-infrastructure-for-bulk-object-allocation-and-freeing-v3-fix
+++ a/mm/slab.c
@@ -3425,7 +3425,7 @@ EXPORT_SYMBOL(kmem_cache_free_bulk);
 bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 								void **p)
 {
-	return kmem_cache_alloc_bulk(s, flags, size, p);
+	return __kmem_cache_alloc_bulk(s, flags, size, p);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
