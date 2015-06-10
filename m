Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B92076B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:52:07 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so31157152pdj.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:52:07 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id pn8si12355537pbb.126.2015.06.09.23.52.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 23:52:07 -0700 (PDT)
Received: by payr10 with SMTP id r10so28806929pay.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:52:06 -0700 (PDT)
Date: Wed, 10 Jun 2015 15:52:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
Message-ID: <20150610065232.GC566@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
 <1433894769.2730.87.camel@perches.com>
 <alpine.DEB.2.02.1506100743200.2087@localhost6.localdomain6>
 <20150610064108.GB566@swordfish>
 <alpine.DEB.2.02.1506100841420.2087@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1506100841420.2087@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/10/15 08:44), Julia Lawall wrote:
> > 
> > [..]
> > 
> > err_percpu_counter_init:
> > 	kmem_cache_destroy(sctp_chunk_cachep);
> > err_chunk_cachep:
> > 	kmem_cache_destroy(sctp_bucket_cachep);
> > 
> > [..]
> > 
> > and others.
> 
> This I find much less appealing.  The labels make clear what is needed
>

hm, agree.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
