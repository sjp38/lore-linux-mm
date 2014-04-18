Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id CA85D6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:26:27 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so1858997eek.29
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:26:27 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id r9si41347444eew.348.2014.04.18.11.26.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 11:26:26 -0700 (PDT)
Date: Fri, 18 Apr 2014 14:26:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC -mm v2 3/3] memcg, slab: simplify synchronization
 scheme
Message-ID: <20140418182614.GH29210@cmpxchg.org>
References: <cover.1397804745.git.vdavydov@parallels.com>
 <c3c36df83d582f8fac94bb716b82406e24229cad.1397804745.git.vdavydov@parallels.com>
 <20140418141734.GD26283@cmpxchg.org>
 <53514DF1.804@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53514DF1.804@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Fri, Apr 18, 2014 at 08:08:17PM +0400, Vladimir Davydov wrote:
> On 04/18/2014 06:17 PM, Johannes Weiner wrote:
> > I like this patch, but the API names are confusing.  Could we fix up
> > that whole thing by any chance?  Some suggestions below, but they
> > might only be marginally better...
> 
> Yeah, names are inconsistent in kmemcg and desperately want improvement:
> 
> mem_cgroup_destroy_all_caches
> kmem_cgroup_css_offline
> memcg_kmem_get_cache
> memcg_charge_kmem
> memcg_create_cache_name
> 
> I've been thinking on cleaning this up for some time, but couldn't make
> up my mind to do this. I think it cannot wait any more now, so my next
> patch set will rework kmemcg naming.
> 
> Can we apply this patch as is for now? It'd be more convenient for me to
> rework naming on top of the end picture.

Yes, absolutely.  For this patch:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
