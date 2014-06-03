Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 636036B00BC
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 21:35:05 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id to1so5315434ieb.16
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 18:35:05 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id h4si28270165ict.19.2014.06.02.18.35.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 18:35:04 -0700 (PDT)
Received: by mail-ig0-f182.google.com with SMTP id uy17so4179133igb.9
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 18:35:04 -0700 (PDT)
Date: Mon, 2 Jun 2014 18:35:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] slab: delete cache from list after __kmem_cache_shutdown
 succeeds
In-Reply-To: <1400159291-5330-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.02.1406021834500.13072@chino.kir.corp.google.com>
References: <1400159291-5330-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Thu, 15 May 2014, Vladimir Davydov wrote:

> Currently, on kmem_cache_destroy we delete the cache from the slab_list
> before __kmem_cache_shutdown, inserting it back to the list on failure.
> Initially, this was done, because we could release the slab_mutex in
> __kmem_cache_shutdown to delete sysfs slub entry, but since commit
> 41a212859a4d ("slub: use sysfs'es release mechanism for kmem_cache") we
> remove sysfs entry later in kmem_cache_destroy after dropping the
> slab_mutex, so that no implementation of __kmem_cache_shutdown can ever
> release the lock. Therefore we can simplify the code a bit by moving
> list_del after __kmem_cache_shutdown.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
