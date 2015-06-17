Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8D04C6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:51:39 -0400 (EDT)
Received: by padev16 with SMTP id ev16so47345966pad.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:51:39 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id wn3si8583155pab.7.2015.06.17.16.51.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 16:51:38 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so52008833pdb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:51:38 -0700 (PDT)
Date: Thu, 18 Jun 2015 08:52:05 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 1/5] mm/slab_common: allow NULL cache pointer in
 kmem_cache_destroy()
Message-ID: <20150617235205.GA3422@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433851493-23685-2-git-send-email-sergey.senozhatsky@gmail.com>
 <alpine.DEB.2.10.1506171613170.8203@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506171613170.8203@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/17/15 16:14), David Rientjes wrote:
[..]
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > LKML-reference: https://lkml.org/lkml/2015/6/8/583
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> kmem_cache_destroy() isn't a fastpath, this is long overdue.  Now where's 
> the patch to remove the NULL checks from the callers? ;)
> 

Thanks.

Yes, Julia Lawall (Cc'd) already has a patch set ready for submission.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
