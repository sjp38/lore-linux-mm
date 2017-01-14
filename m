Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B17A6B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:30:08 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id o12so31191101lfg.7
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 05:30:07 -0800 (PST)
Received: from smtp48.i.mail.ru (smtp48.i.mail.ru. [94.100.177.108])
        by mx.google.com with ESMTPS id m28si6016908lfj.63.2017.01.14.05.30.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 05:30:06 -0800 (PST)
Date: Sat, 14 Jan 2017 16:30:00 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 4/9] slab: reorganize memcg_cache_params
Message-ID: <20170114133000.GC2668@esperanza>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-5-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114055449.11044-5-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 12:54:44AM -0500, Tejun Heo wrote:
> We're gonna change how memcg caches are iterated.  In preparation,
> clean up and reorganize memcg_cache_params.
> 
> * The shared ->list is replaced by ->children in root and
>   ->children_node in children.
> 
> * ->is_root_cache is removed.  Instead ->root_cache is moved out of
>   the child union and now used by both root and children.  NULL
>   indicates root cache.  Non-NULL a memcg one.
> 
> This patch doesn't cause any observable behavior changes.
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
