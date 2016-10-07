Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47CD56B0261
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 01:14:21 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n202so36972825oig.2
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 22:14:21 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n81si15798129oib.90.2016.10.06.22.14.19
        for <linux-mm@kvack.org>;
        Thu, 06 Oct 2016 22:14:20 -0700 (PDT)
Date: Fri, 7 Oct 2016 14:14:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/slab: fix kmemcg cache creation delayed issue
Message-ID: <20161007051400.GA7294@js1304-P5Q-DELUXE>
References: <002b01d21fea$fb0bab60$f1230220$@net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002b01d21fea$fb0bab60$f1230220$@net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Smythies <dsmythies@telus.net>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Christoph Lameter' <cl@linux.com>, 'Pekka Enberg' <penberg@kernel.org>, 'David Rientjes' <rientjes@google.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vladimir Davydov' <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, Oct 06, 2016 at 09:02:00AM -0700, Doug Smythies wrote:
> It was my (limited) understanding that the subsequent 2 patch set
> superseded this patch. Indeed, the 2 patch set seems to solve
> both the SLAB and SLUB bug reports.

It would mean that patch 1 solves both the SLAB and SLUB bug reports
since patch 2 is only effective for SLUB.

Reason that I send this patch is that although patch 1 fixes the
issue that too many kworkers are created, kmem_cache creation/destory
is still slowed by synchronize_sched() and it would cause kmemcg
usage counting delayed. I'm not sure how bad it is but it's generally
better to start accounting as soon as possible. With patch 2 for SLUB
and this patch for SLAB, performance of kmem_cache
creation/destory would recover.

Thanks.

> 
> References:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=172981
> https://bugzilla.kernel.org/show_bug.cgi?id=172991
> https://patchwork.kernel.org/patch/9361853
> https://patchwork.kernel.org/patch/9359271

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
