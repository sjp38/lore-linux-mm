Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF5A6B0255
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 10:22:31 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so28845255pac.3
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 07:22:31 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id pw9si11684418pbc.214.2015.08.06.07.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 07:22:30 -0700 (PDT)
Received: by pdber20 with SMTP id er20so32869522pdb.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 07:22:30 -0700 (PDT)
Date: Thu, 6 Aug 2015 23:21:31 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCH 1/5] mm/slab_common: allow NULL cache pointer in
 kmem_cache_destroy()
Message-ID: <20150806142131.GB4292@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com>
 <alpine.DEB.2.10.1506171613170.8203@chino.kir.corp.google.com>
 <20150617235205.GA3422@swordfish>
 <alpine.DEB.2.10.1506190850060.2584@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506190850060.2584@hadrien>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/19/15 08:50), Julia Lawall wrote:
> On Thu, 18 Jun 2015, Sergey Senozhatsky wrote:
> 
> > On (06/17/15 16:14), David Rientjes wrote:
> > [..]
> > > >
> > > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > > > LKML-reference: https://lkml.org/lkml/2015/6/8/583
> > >
> > > Acked-by: David Rientjes <rientjes@google.com>
> > >
> > > kmem_cache_destroy() isn't a fastpath, this is long overdue.  Now where's
> > > the patch to remove the NULL checks from the callers? ;)
> > >
> >
> > Thanks.
> >
> > Yes, Julia Lawall (Cc'd) already has a patch set ready for submission.
> 
> I'll refresh it and send it shortly.
> 

I'll re-up this thread.

Julia, do you want to wait until these 3 patches will be merged to
Linus's tree (just to be on a safe side, so someone's tree (out of sync
with linux-next) will not go crazy)?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
