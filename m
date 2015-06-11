Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2CD76B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 05:51:20 -0400 (EDT)
Received: by payr10 with SMTP id r10so1377953pay.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 02:51:20 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id lt3si198705pab.125.2015.06.11.02.51.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 02:51:20 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so1296536pab.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 02:51:19 -0700 (PDT)
Date: Thu, 11 Jun 2015 18:51:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH V2] checkpatch: Add some <foo>_destroy functions to
 NEEDLESS_IF tests
Message-ID: <20150611095144.GC515@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
 <1433894769.2730.87.camel@perches.com>
 <1433911166.2730.98.camel@perches.com>
 <1433915549.2730.107.camel@perches.com>
 <alpine.DEB.2.10.1506111140240.2320@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506111140240.2320@hadrien>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On (06/11/15 11:41), Julia Lawall wrote:
> On Tue, 9 Jun 2015, Joe Perches wrote:
> 
> > Sergey Senozhatsky has modified several destroy functions that can
> > now be called with NULL values.
> >
> >  - kmem_cache_destroy()
> >  - mempool_destroy()
> >  - dma_pool_destroy()
> 
> I don't actually see any null test in the definition of dma_pool_destroy,
> in the linux-next 54896f27dd5 (20150610).  So I guess it would be
> premature to send patches to remove the null tests.
> 

yes,

Andrew Morton:
: I'll park these patches until after 4.1 is released - it's getting to
: that time...


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
