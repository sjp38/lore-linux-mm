Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6600A6B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:00:28 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id z134so110563146lff.5
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 10:00:28 -0800 (PST)
Received: from smtp17.mail.ru (smtp17.mail.ru. [94.100.176.154])
        by mx.google.com with ESMTPS id v2si3290893ljb.65.2017.01.27.10.00.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 10:00:26 -0800 (PST)
Date: Fri, 27 Jan 2017 21:00:12 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH v2 02/10] slub: separate out sysfs_slab_release() from
 sysfs_slab_remove()
Message-ID: <20170127180012.GA4332@esperanza>
References: <20170117235411.9408-1-tj@kernel.org>
 <20170117235411.9408-3-tj@kernel.org>
 <20170123225449.GA29940@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123225449.GA29940@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 05:54:49PM -0500, Tejun Heo wrote:
> From 3b0cdd93b2d9bdea62ea6681e612bdae7a40d883 Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj@kernel.org>
> Date: Mon, 23 Jan 2017 17:53:18 -0500
> 
> Separate out slub sysfs removal and release, and call the former
> earlier from __kmem_cache_shutdown().  There's no reason to defer
> sysfs removal through RCU and this will later allow us to remove sysfs
> files way earlier during memory cgroup offline instead of release.
> 
> v2: Add slab_state >= FULL test to sysfs_slab_release() so that
>     kobject_put() is skipped for caches which aren't fully initialized
>     as before.  This most likely leaks the kmem_cache on init failure
>     as we're skipping the only release path.  Let's fix that up later.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
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
