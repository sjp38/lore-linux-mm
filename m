Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 762296B0035
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:08:23 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id mc6so1474207lab.22
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:08:22 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id iz10si19268742lbc.165.2014.04.18.09.08.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Apr 2014 09:08:21 -0700 (PDT)
Message-ID: <53514DF1.804@parallels.com>
Date: Fri, 18 Apr 2014 20:08:17 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC -mm v2 3/3] memcg, slab: simplify synchronization
 scheme
References: <cover.1397804745.git.vdavydov@parallels.com> <c3c36df83d582f8fac94bb716b82406e24229cad.1397804745.git.vdavydov@parallels.com> <20140418141734.GD26283@cmpxchg.org>
In-Reply-To: <20140418141734.GD26283@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 04/18/2014 06:17 PM, Johannes Weiner wrote:
> I like this patch, but the API names are confusing.  Could we fix up
> that whole thing by any chance?  Some suggestions below, but they
> might only be marginally better...

Yeah, names are inconsistent in kmemcg and desperately want improvement:

mem_cgroup_destroy_all_caches
kmem_cgroup_css_offline
memcg_kmem_get_cache
memcg_charge_kmem
memcg_create_cache_name

I've been thinking on cleaning this up for some time, but couldn't make
up my mind to do this. I think it cannot wait any more now, so my next
patch set will rework kmemcg naming.

Can we apply this patch as is for now? It'd be more convenient for me to
rework naming on top of the end picture.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
