Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 60EB72802E6
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 04:26:13 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so39102810pac.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 01:26:13 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id yd8si11775409pbc.112.2015.07.16.01.26.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 01:26:12 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so41786348pdb.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 01:26:11 -0700 (PDT)
Date: Thu, 16 Jul 2015 17:26:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 1/5] mm/slab_common: allow NULL cache pointer in
 kmem_cache_destroy()
Message-ID: <20150716082643.GA622@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com>
 <alpine.DEB.2.10.1506171613170.8203@chino.kir.corp.google.com>
 <20150617235205.GA3422@swordfish>
 <alpine.DEB.2.02.1506201824510.2067@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1506201824510.2067@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/20/15 18:25), Julia Lawall wrote:
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
> The patch for making these functions able to tolerate NULL doesn't seem to 
> be in linux-next yet, so I will wait until it appears.

Hello Julia,

The patches are in -next now.

mm/dmapool: 8bf49946ed8fa01a0b5e7d0de94655c072525344
mm/mempool: eb54bc8469e2977bcef4e284d24cbf3578ce9cd9
mm/slab_common: e88672f95907c14cf8ab2cce592c41bbb9cefc5f

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
