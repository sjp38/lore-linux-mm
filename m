Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 276D06B006E
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 14:19:22 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so122329956pab.3
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 11:19:21 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gh3si17398640pbd.145.2015.04.08.11.19.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 11:19:21 -0700 (PDT)
Date: Wed, 8 Apr 2015 21:19:11 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm] slab: use cgroup ino for naming per memcg caches
Message-ID: <20150408181911.GA18199@esperanza>
References: <1428414798-12932-1-git-send-email-vdavydov@parallels.com>
 <20150407133819.993be7a53a3aa16311aba1f5@linux-foundation.org>
 <20150408095404.GC10286@esperanza>
 <alpine.DEB.2.11.1504080845200.13120@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504080845200.13120@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 08, 2015 at 08:46:22AM -0500, Christoph Lameter wrote:
> On Wed, 8 Apr 2015, Vladimir Davydov wrote:
> 
> > has its own copy of kmem cache. What if we decide to share the same kmem
> > cache among all memory cgroups one day? Of course, this will hardly ever
> > happen, but it is an alternative approach to implementing the same
> 
> /sys/kernel/slab already supports the use of symlinks. And both SLAB and
> SLUB do slab merging which means effectively an aliasing of multiple slab
> caches to the same name.

Yeah, I think cache merging is a good argument for grouping memcg caches
under /sys/kernel/slab/<slab-name>/cgroup/. We cannot maintain symlinks
for merged memcg caches, because when a memcg cache is created we do not
have names of caches the new cache is merged with. If memcg caches were
listed under /sys/kernel/slab/ along with global ones, absence of the
symlinks would lead to confusion.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
