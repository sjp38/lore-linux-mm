Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 02D3A6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 10:27:11 -0400 (EDT)
Received: by iget9 with SMTP id t9so105264795ige.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 07:27:10 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id mv8si13582263igb.62.2015.04.22.07.27.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 07:27:10 -0700 (PDT)
Date: Wed, 22 Apr 2015 09:27:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slab_common: Support the slub_debug boot option
 on specific object size
In-Reply-To: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
Message-ID: <alpine.DEB.2.11.1504220926480.24618@gentwo.org>
References: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 22 Apr 2015, Gavin Guo wrote:

> The slub_debug=PU,kmalloc-xx cannot work because in the
> create_kmalloc_caches() the s->name is created after the
> create_kmalloc_cache() is called. The name is NULL in the
> create_kmalloc_cache() so the kmem_cache_flags() would not set the
> slub_debug flags to the s->flags. The fix here set up a kmalloc_names
> string array for the initialization purpose and delete the dynamic
> name creation of kmalloc_caches.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
