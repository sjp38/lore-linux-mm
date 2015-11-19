Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 024166B0256
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:01:45 -0500 (EST)
Received: by wmww144 with SMTP id w144so129762808wmw.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 11:01:44 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o6si1657979wjo.220.2015.11.19.11.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 11:01:44 -0800 (PST)
Date: Thu, 19 Nov 2015 14:01:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 4/6] slab: add SLAB_ACCOUNT flag
Message-ID: <20151119190134.GD3941@cmpxchg.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 10, 2015 at 09:34:05PM +0300, Vladimir Davydov wrote:
> Currently, if we want to account all objects of a particular kmem cache,
> we have to pass __GFP_ACCOUNT to each kmem_cache_alloc call, which is
> inconvenient. This patch introduces SLAB_ACCOUNT flag which if passed to
> kmem_cache_create will force accounting for every allocation from this
> cache even if __GFP_ACCOUNT is not passed.
> 
> This patch does not make any of the existing caches use this flag - it
> will be done later in the series.
> 
> Note, a cache with SLAB_ACCOUNT cannot be merged with a cache w/o
> SLAB_ACCOUNT, i.e. using this flag will probably reduce the number of
> merged slabs even if kmem accounting is not used (only compiled in).
> 
> Suggested-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
