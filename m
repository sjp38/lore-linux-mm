Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4366B0257
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 10:27:39 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so25006033wic.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 07:27:38 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id n18si4365747wij.109.2015.08.06.07.27.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Aug 2015 07:27:37 -0700 (PDT)
Date: Thu, 6 Aug 2015 16:27:31 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [RFC][PATCH 1/5] mm/slab_common: allow NULL cache pointer in
 kmem_cache_destroy()
In-Reply-To: <20150806142131.GB4292@swordfish>
Message-ID: <alpine.DEB.2.10.1508061626560.2343@hadrien>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com> <alpine.DEB.2.10.1506171613170.8203@chino.kir.corp.google.com> <20150617235205.GA3422@swordfish>
 <alpine.DEB.2.10.1506190850060.2584@hadrien> <20150806142131.GB4292@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Thu, 6 Aug 2015, Sergey Senozhatsky wrote:

> On (06/19/15 08:50), Julia Lawall wrote:
> > On Thu, 18 Jun 2015, Sergey Senozhatsky wrote:
> >
> > > On (06/17/15 16:14), David Rientjes wrote:
> > > [..]
> > > > >
> > > > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > > > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > > > > LKML-reference: https://lkml.org/lkml/2015/6/8/583
> > > >
> > > > Acked-by: David Rientjes <rientjes@google.com>
> > > >
> > > > kmem_cache_destroy() isn't a fastpath, this is long overdue.  Now where's
> > > > the patch to remove the NULL checks from the callers? ;)
> > > >
> > >
> > > Thanks.
> > >
> > > Yes, Julia Lawall (Cc'd) already has a patch set ready for submission.
> >
> > I'll refresh it and send it shortly.
> >
>
> I'll re-up this thread.
>
> Julia, do you want to wait until these 3 patches will be merged to
> Linus's tree (just to be on a safe side, so someone's tree (out of sync
> with linux-next) will not go crazy)?

I think it would be safer.  Code may crash if the test is removed before
the function can tolerate it.

julia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
