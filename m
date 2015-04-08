Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id B31926B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 09:46:25 -0400 (EDT)
Received: by iebmp1 with SMTP id mp1so74083936ieb.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 06:46:25 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id n65si9572525ioi.107.2015.04.08.06.46.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 06:46:25 -0700 (PDT)
Date: Wed, 8 Apr 2015 08:46:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] slab: use cgroup ino for naming per memcg caches
In-Reply-To: <20150408095404.GC10286@esperanza>
Message-ID: <alpine.DEB.2.11.1504080845200.13120@gentwo.org>
References: <1428414798-12932-1-git-send-email-vdavydov@parallels.com> <20150407133819.993be7a53a3aa16311aba1f5@linux-foundation.org> <20150408095404.GC10286@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 8 Apr 2015, Vladimir Davydov wrote:

> has its own copy of kmem cache. What if we decide to share the same kmem
> cache among all memory cgroups one day? Of course, this will hardly ever
> happen, but it is an alternative approach to implementing the same

/sys/kernel/slab already supports the use of symlinks. And both SLAB and
SLUB do slab merging which means effectively an aliasing of multiple slab
caches to the same name.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
