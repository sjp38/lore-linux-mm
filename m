Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id AD8FD6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 05:56:02 -0400 (EDT)
Received: by wifx6 with SMTP id x6so5138338wif.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 02:56:02 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id fw6si15284360wib.35.2015.06.11.02.56.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 02:56:01 -0700 (PDT)
Date: Thu, 11 Jun 2015 11:55:50 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH V2] checkpatch: Add some <foo>_destroy functions to
 NEEDLESS_IF tests
In-Reply-To: <20150611095144.GC515@swordfish>
Message-ID: <alpine.DEB.2.10.1506111155390.2320@hadrien>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org> <1433894769.2730.87.camel@perches.com> <1433911166.2730.98.camel@perches.com> <1433915549.2730.107.camel@perches.com>
 <alpine.DEB.2.10.1506111140240.2320@hadrien> <20150611095144.GC515@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Thu, 11 Jun 2015, Sergey Senozhatsky wrote:

> On (06/11/15 11:41), Julia Lawall wrote:
> > On Tue, 9 Jun 2015, Joe Perches wrote:
> >
> > > Sergey Senozhatsky has modified several destroy functions that can
> > > now be called with NULL values.
> > >
> > >  - kmem_cache_destroy()
> > >  - mempool_destroy()
> > >  - dma_pool_destroy()
> >
> > I don't actually see any null test in the definition of dma_pool_destroy,
> > in the linux-next 54896f27dd5 (20150610).  So I guess it would be
> > premature to send patches to remove the null tests.
> >
>
> yes,
>
> Andrew Morton:
> : I'll park these patches until after 4.1 is released - it's getting to
> : that time...

OK, thanks,

julia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
