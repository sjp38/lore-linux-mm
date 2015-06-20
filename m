Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 055CA6B009E
	for <linux-mm@kvack.org>; Sat, 20 Jun 2015 12:25:37 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so42781699wic.1
        for <linux-mm@kvack.org>; Sat, 20 Jun 2015 09:25:36 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id i2si10657357wie.61.2015.06.20.09.25.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 20 Jun 2015 09:25:35 -0700 (PDT)
Date: Sat, 20 Jun 2015 18:25:33 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [RFC][PATCH 1/5] mm/slab_common: allow NULL cache pointer in
 kmem_cache_destroy()
In-Reply-To: <20150617235205.GA3422@swordfish>
Message-ID: <alpine.DEB.2.02.1506201824510.2067@localhost6.localdomain6>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com> <alpine.DEB.2.10.1506171613170.8203@chino.kir.corp.google.com> <20150617235205.GA3422@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>



On Thu, 18 Jun 2015, Sergey Senozhatsky wrote:

> On (06/17/15 16:14), David Rientjes wrote:
> [..]
> > > 
> > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > > LKML-reference: https://lkml.org/lkml/2015/6/8/583
> > 
> > Acked-by: David Rientjes <rientjes@google.com>
> > 
> > kmem_cache_destroy() isn't a fastpath, this is long overdue.  Now where's 
> > the patch to remove the NULL checks from the callers? ;)
> > 
> 
> Thanks.
> 
> Yes, Julia Lawall (Cc'd) already has a patch set ready for submission.

The patch for making these functions able to tolerate NULL doesn't seem to 
be in linux-next yet, so I will wait until it appears.

julia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
