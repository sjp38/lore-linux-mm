Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AF60B6B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:12:51 -0500 (EST)
Received: by padhx2 with SMTP id hx2so47106740pad.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 17:12:51 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id to8si16111076pab.76.2015.11.11.17.12.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 17:12:51 -0800 (PST)
Received: by pasz6 with SMTP id z6so48578953pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 17:12:50 -0800 (PST)
Date: Thu, 12 Nov 2015 10:13:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] tools/vm/slabinfo: update struct slabinfo members'
 types
Message-ID: <20151112011347.GC1651@swordfish>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1447162326-30626-4-git-send-email-sergey.senozhatsky@gmail.com>
 <alpine.DEB.2.10.1511111251030.4742@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511111251030.4742@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (11/11/15 12:55), David Rientjes wrote:
[..]
> >  	/* Object size */
> > -	unsigned long long min_objsize = max, max_objsize = 0, avg_objsize;
> > +	unsigned int min_objsize = UINT_MAX, max_objsize = 0, avg_objsize;
> >  
> >  	/* Number of partial slabs in a slabcache */
> >  	unsigned long long min_partial = max, max_partial = 0,
> 
> avg_objsize should not be unsigned int.

Hm. the assumption is that `avg_objsize' cannot be larger
than `max_objsize', which is
	`int object_size;' in `struct kmem_cache' from slab_def.h
and
	`unsigned int object_size;' in `struct kmem_cache' from slab.h.


 avg_objsize = total_used / total_objects;


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
