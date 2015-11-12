Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4606B025D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:07:07 -0500 (EST)
Received: by pasz6 with SMTP id z6so54956139pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 21:07:06 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id wv1si17346512pab.150.2015.11.11.21.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 21:07:06 -0800 (PST)
Received: by padhx2 with SMTP id hx2so53234311pad.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 21:07:06 -0800 (PST)
Date: Wed, 11 Nov 2015 21:07:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] tools/vm/slabinfo: update struct slabinfo members'
 types
In-Reply-To: <20151112011347.GC1651@swordfish>
Message-ID: <alpine.DEB.2.10.1511112105200.9296@chino.kir.corp.google.com>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com> <1447162326-30626-4-git-send-email-sergey.senozhatsky@gmail.com> <alpine.DEB.2.10.1511111251030.4742@chino.kir.corp.google.com> <20151112011347.GC1651@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 12 Nov 2015, Sergey Senozhatsky wrote:

> > >  	/* Object size */
> > > -	unsigned long long min_objsize = max, max_objsize = 0, avg_objsize;
> > > +	unsigned int min_objsize = UINT_MAX, max_objsize = 0, avg_objsize;
> > >  
> > >  	/* Number of partial slabs in a slabcache */
> > >  	unsigned long long min_partial = max, max_partial = 0,
> > 
> > avg_objsize should not be unsigned int.
> 
> Hm. the assumption is that `avg_objsize' cannot be larger
> than `max_objsize', which is
> 	`int object_size;' in `struct kmem_cache' from slab_def.h
> and
> 	`unsigned int object_size;' in `struct kmem_cache' from slab.h.
> 
> 
>  avg_objsize = total_used / total_objects;
> 

total_used and total_objects are unsigned long long.  This has nothing to 
do with object_size in the kernel.  If you need to convert max_objsize to 
be unsigned long long as well, that would be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
