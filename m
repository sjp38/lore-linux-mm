Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 319006B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 11:07:36 -0500 (EST)
Received: by pasz6 with SMTP id z6so35692595pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:07:35 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ga3si13507224pbb.56.2015.11.11.08.07.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 08:07:35 -0800 (PST)
Date: Wed, 11 Nov 2015 19:07:19 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2 4/6] slab: add SLAB_ACCOUNT flag
Message-ID: <20151111160719.GX31308@esperanza>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
 <20151110183808.GB13740@mtj.duckdns.org>
 <20151110185401.GW31308@esperanza>
 <20151111155450.GB6246@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151111155450.GB6246@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Nov 11, 2015 at 10:54:50AM -0500, Tejun Heo wrote:
> Hello,
> 
> On Tue, Nov 10, 2015 at 09:54:01PM +0300, Vladimir Davydov wrote:
> > > Am I correct in thinking that we should eventually be able to removed
> > > __GFP_ACCOUNT and that only caches explicitly marked with SLAB_ACCOUNT
> > > would need to be handled by kmemcg?
> > 
> > Don't think so, because sometimes we want to account kmalloc.
> 
> I'm kinda skeptical about that because if those allocations are
> occassional by nature, we don't care and if there can be a huge number
> of them, splitting them into a separate cache makes sense.  I think it
> makes sense to pin down exactly which caches are memcg managed.  That
> has the potential to simplify the involved code path and shave off a
> small bit of hot path overhead.

What about external_name allocation in __d_alloc? Is it occasional?
Depends on the workload I guess. Can we create a separate cache for it?
No, because its size is variable. There are other things like that, e.g.
pipe_buffer array.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
