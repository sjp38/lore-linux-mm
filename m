Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id E88176B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:32:55 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id la4so2162742vcb.35
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:32:55 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id ot8si3057653vcb.95.2014.05.30.07.32.55
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 07:32:55 -0700 (PDT)
Date: Fri, 30 May 2014 09:32:52 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 2/8] memcg: destroy kmem caches when last slab is
 freed
In-Reply-To: <ec6f290739074232ce1eeddc455ee14d471a70db.1401457502.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405300932400.11943@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <ec6f290739074232ce1eeddc455ee14d471a70db.1401457502.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 May 2014, Vladimir Davydov wrote:

> When the memcg_cache_params->refcnt goes to 0, schedule the worker that
> will unregister the cache. To prevent this from happening when the owner
> memcg is alive, keep the refcnt incremented during memcg lifetime.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
