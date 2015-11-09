Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id E1AB66B0257
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 14:33:00 -0500 (EST)
Received: by ykek133 with SMTP id k133so283692587yke.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 11:33:00 -0800 (PST)
Received: from mail-yk0-x234.google.com (mail-yk0-x234.google.com. [2607:f8b0:4002:c07::234])
        by mx.google.com with ESMTPS id o133si8943132ywb.309.2015.11.09.11.32.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 11:32:58 -0800 (PST)
Received: by ykdr82 with SMTP id r82so8405835ykd.3
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 11:32:58 -0800 (PST)
Date: Mon, 9 Nov 2015 14:32:53 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151109193253.GC28507@mtj.duckdns.org>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
 <20151109182840.GJ31308@esperanza>
 <20151109185401.GB28507@mtj.duckdns.org>
 <20151109192747.GN31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151109192747.GN31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Vladmir.

On Mon, Nov 09, 2015 at 10:27:47PM +0300, Vladimir Davydov wrote:
> Of course, we could rework slab merging so that kmem_cache_create
> returned a new dummy cache even if it was actually merged. Such a cache
> would point to the real cache, which would be used for allocations. This
> wouldn't limit slab merging, but this would add one more dereference to
> alloc path, which is even worse.

Hmmm, this could be me not really understanding but why can't we let
all slabs to be merged regardless of SLAB_ACCOUNT flag for root memcg
and point to per-memcg slabs (may be merged among them but most likely
won't matter) for !root.  We're indirecting once anyway, no?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
