Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABE3B6B0276
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 11:04:27 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id h65so123945598lfi.1
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 08:04:27 -0800 (PST)
Received: from smtp46.i.mail.ru (smtp46.i.mail.ru. [94.100.177.106])
        by mx.google.com with ESMTPS id o69si6552899lfi.257.2017.01.29.08.04.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 29 Jan 2017 08:04:26 -0800 (PST)
Date: Sun, 29 Jan 2017 19:04:17 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 10/10] slab: use memcg_kmem_cache_wq for slab destruction
 operations
Message-ID: <20170129160416.GA1795@esperanza>
References: <20170117235411.9408-1-tj@kernel.org>
 <20170117235411.9408-11-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117235411.9408-11-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 17, 2017 at 03:54:11PM -0800, Tejun Heo wrote:
> If there's contention on slab_mutex, queueing the per-cache
> destruction work item on the system_wq can unnecessarily create and
> tie up a lot of kworkers.
> 
> Rename memcg_kmem_cache_create_wq to memcg_kmem_cache_wq and make it
> global and use that workqueue for the destruction work items too.
> While at it, convert the workqueue from an unbound workqueue to a
> per-cpu one with concurrency limited to 1.  It's generally preferable
> to use per-cpu workqueues and concurrency limit of 1 is safe enough.
> 
> This is suggested by Joonsoo Kim.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Jay Vana <jsvana@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
