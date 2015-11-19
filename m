Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id EB1886B0256
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:00:26 -0500 (EST)
Received: by wmww144 with SMTP id w144so251045831wmw.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 11:00:26 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z76si13885520wmz.87.2015.11.19.11.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 11:00:26 -0800 (PST)
Date: Thu, 19 Nov 2015 14:00:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 3/6] memcg: only account kmem allocations marked as
 __GFP_ACCOUNT
Message-ID: <20151119190015.GC3941@cmpxchg.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <14d7a7f5e696d71793ddd835604de309af1963fd.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14d7a7f5e696d71793ddd835604de309af1963fd.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 10, 2015 at 09:34:04PM +0300, Vladimir Davydov wrote:
> Black-list kmem accounting policy (aka __GFP_NOACCOUNT) turned out to be
> fragile and difficult to maintain, because there seem to be many more
> allocations that should not be accounted than those that should be.
> Besides, false accounting an allocation might result in much worse
> consequences than not accounting at all, namely increased memory
> consumption due to pinned dead kmem caches.
> 
> So this patch switches kmem accounting to the white-policy: now only
> those kmem allocations that are marked as __GFP_ACCOUNT are accounted to
> memcg. Currently, no kmem allocations are marked like this. The
> following patches will mark several kmem allocations that are known to
> be easily triggered from userspace and therefore should be accounted to
> memcg.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
