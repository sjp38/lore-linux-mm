Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id DA2166B0257
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 13:38:11 -0500 (EST)
Received: by ykdr82 with SMTP id r82so8902858ykd.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:38:11 -0800 (PST)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id w66si2498738ywe.143.2015.11.10.10.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 10:38:11 -0800 (PST)
Received: by ykba77 with SMTP id a77so8926200ykb.2
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:38:11 -0800 (PST)
Date: Tue, 10 Nov 2015 13:38:08 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 4/6] slab: add SLAB_ACCOUNT flag
Message-ID: <20151110183808.GB13740@mtj.duckdns.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

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

Am I correct in thinking that we should eventually be able to removed
__GFP_ACCOUNT and that only caches explicitly marked with SLAB_ACCOUNT
would need to be handled by kmemcg?

Thanks a lot for doing this!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
