Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 82AC46B0075
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:15:02 -0400 (EDT)
Received: by igbzc4 with SMTP id zc4so114981470igb.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:15:02 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id i10si5115308icx.60.2015.06.17.16.15.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 16:15:00 -0700 (PDT)
Received: by igblz2 with SMTP id lz2so48074194igb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:15:00 -0700 (PDT)
Date: Wed, 17 Jun 2015 16:14:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 1/5] mm/slab_common: allow NULL cache pointer in
 kmem_cache_destroy()
In-Reply-To: <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com>
Message-ID: <alpine.DEB.2.10.1506171613170.8203@chino.kir.corp.google.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Tue, 9 Jun 2015, Sergey Senozhatsky wrote:

> kmem_cache_destroy() does not tolerate a NULL kmem_cache pointer
> argument and performs a NULL-pointer dereference. This requires
> additional attention and effort from developers/reviewers and
> forces all kmem_cache_destroy() callers (200+ as of 4.1) to do
> a NULL check
> 
> 	if (cache)
> 		kmem_cache_destroy(cache);
> 
> Or, otherwise, be invalid kmem_cache_destroy() users.
> 
> Tweak kmem_cache_destroy() and NULL-check the pointer there.
> 
> Proposed by Andrew Morton.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> LKML-reference: https://lkml.org/lkml/2015/6/8/583

Acked-by: David Rientjes <rientjes@google.com>

kmem_cache_destroy() isn't a fastpath, this is long overdue.  Now where's 
the patch to remove the NULL checks from the callers? ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
