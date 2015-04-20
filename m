Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 89C396B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:40:39 -0400 (EDT)
Received: by iebrs15 with SMTP id rs15so119295000ieb.3
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 08:40:39 -0700 (PDT)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id l64si16058174iod.39.2015.04.20.08.40.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 08:40:39 -0700 (PDT)
Date: Mon, 20 Apr 2015 10:40:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab_common: Support the slub_debug boot option on
 specific object size
In-Reply-To: <1429349091-11785-1-git-send-email-gavin.guo@canonical.com>
Message-ID: <alpine.DEB.2.11.1504201040010.2264@gentwo.org>
References: <1429349091-11785-1-git-send-email-gavin.guo@canonical.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 18 Apr 2015, Gavin Guo wrote:

> The slub_debug=PU,kmalloc-xx cannot work because in the
> create_kmalloc_caches() the s->name is created after the
> create_kmalloc_cache() is called. The name is NULL in the
> create_kmalloc_cache() so the kmem_cache_flags() would not set the
> slub_debug flags to the s->flags. The fix here set up a temporary
> kmalloc_names string array for the initialization purpose. After the
> kmalloc_caches are already it can be used to create s->name in the
> kasprintf.

Ok if you do that then the dynamic creation of the kmalloc hostname can
also be removed. This patch should do that as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
