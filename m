Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFA06B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:13:58 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j5so2957457qaq.1
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:13:57 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id e4si18275945qaf.77.2014.06.02.08.13.57
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 08:13:57 -0700 (PDT)
Date: Mon, 2 Jun 2014 10:13:54 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 4/8] slub: never fail kmem_cache_shrink
In-Reply-To: <20140531101819.GA25076@esperanza>
Message-ID: <alpine.DEB.2.10.1406021012040.2987@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <ac8907cace921c3209aa821649349106f4f70b34.1401457502.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405300937560.11943@gentwo.org> <20140531101819.GA25076@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 31 May 2014, Vladimir Davydov wrote:

> ... which means more async workers, more complication to kmemcg code :-(
>
> Sorry, but I just don't get why we can't make kmem_cache_shrink never
> fail? Is failing de-fragmentation, which is even not implied by the
> function declaration, so critical that should be noted? If so, we can
> return an error while still shrinking empty slabs...

There could be other reasons for failure in the future as
kmem_cache_shrink is updated. Requiring kmem_cache_shrink to never fail
may cause problems for future modifications.

> If you just don't like the code after the patch, here is another, less
> intrusive version doing practically the same. Would it be better?

That looks acceptable.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
