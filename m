Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3386B6B0254
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 15:30:57 -0500 (EST)
Received: by ykek133 with SMTP id k133so285991834yke.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:30:57 -0800 (PST)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id v13si9112424ywg.289.2015.11.09.12.30.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 12:30:56 -0800 (PST)
Received: by ykdr82 with SMTP id r82so10716100ykd.3
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:30:56 -0800 (PST)
Date: Mon, 9 Nov 2015 15:30:53 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151109203053.GD28507@mtj.duckdns.org>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
 <20151109182840.GJ31308@esperanza>
 <20151109185401.GB28507@mtj.duckdns.org>
 <20151109192747.GN31308@esperanza>
 <20151109193253.GC28507@mtj.duckdns.org>
 <20151109201218.GP31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151109201218.GP31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Vladimir.

On Mon, Nov 09, 2015 at 11:12:18PM +0300, Vladimir Davydov wrote:
> Because we won't be able to distinguish kmem_cache_alloc calls that
> should be accounted from those that shouldn't. The problem is if two
> caches
> 
> 	A = kmem_cache_create(...)
> 
> and
> 
> 	B = kmem_cache_create(...)
> 
> happen to be merged, A and B will point to the same kmem_cache struct.
> As a result, there is no way to distinguish
> 
> 	kmem_cache_alloc(A)
> 
> which we want to account from
> 
> 	kmem_cache_alloc(B)
> 
> which we don't.

Hmm.... can't we simply merge among !SLAB_ACCOUNT and SLAB_ACCOUNT
kmem_caches within themselves?  I don't think we'd be losing anything
by restricting merge at that level.  For anything to be tagged
SLAB_ACCOUNT, it has to have a potential to grow enormous after all.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
