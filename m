Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 115816B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 16:22:25 -0400 (EDT)
Received: by qgeb6 with SMTP id b6so73201228qge.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 13:22:24 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id r25si18557925qkl.128.2015.08.31.13.22.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 31 Aug 2015 13:22:24 -0700 (PDT)
Date: Mon, 31 Aug 2015 15:22:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
In-Reply-To: <20150831192612.GE15420@esperanza>
Message-ID: <alpine.DEB.2.11.1508311521040.30405@east.gentwo.org>
References: <cover.1440960578.git.vdavydov@parallels.com> <20150831132414.GG29723@dhcp22.suse.cz> <20150831134335.GB2271@mtj.duckdns.org> <20150831143007.GA13814@esperanza> <20150831143939.GC2271@mtj.duckdns.org> <20150831151814.GC13814@esperanza>
 <20150831154756.GE2271@mtj.duckdns.org> <20150831165131.GD15420@esperanza> <20150831170309.GF2271@mtj.duckdns.org> <20150831192612.GE15420@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 31 Aug 2015, Vladimir Davydov wrote:

> I totally agree that we should strive to make a kmem user feel roughly
> the same in memcg as if it were running on a host with equal amount of
> RAM. There are two ways to achieve that:
>
>  1. Make the API functions, i.e. kmalloc and friends, behave inside
>     memcg roughly the same way as they do in the root cgroup.
>  2. Make the internal memcg functions, i.e. try_charge and friends,
>     behave roughly the same way as alloc_pages.
>
> I find way 1 more flexible, because we don't have to blindly follow
> heuristics used on global memory reclaim and therefore have more
> opportunities to achieve the same goal.

The heuristics need to integrate well if its in a cgroup or not. In
general make use of cgroups as transparent as possible to the rest of the
code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
