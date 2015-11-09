Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 36C796B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 13:56:20 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so207465153pab.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 10:56:20 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yn6si23976993pab.112.2015.11.09.10.56.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:56:19 -0800 (PST)
Date: Mon, 9 Nov 2015 21:56:07 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V3 2/2] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20151109185607.GL31308@esperanza>
References: <20151109181604.8231.22983.stgit@firesoul>
 <20151109181736.8231.98629.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151109181736.8231.98629.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Mon, Nov 09, 2015 at 07:17:50PM +0100, Jesper Dangaard Brouer wrote:
> Initial implementation missed support for kmem cgroup support
> in kmem_cache_free_bulk() call, add this.
> 
> If CONFIG_MEMCG_KMEM is not enabled, the compiler should
> be smart enough to not add any asm code.
> 
> Incomming bulk free objects can belong to different kmem cgroups, and
> object free call can happen at a later point outside memcg context.
> Thus, we need to keep the orig kmem_cache, to correctly verify if a
> memcg object match against its "root_cache" (s->memcg_params.root_cache).
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
