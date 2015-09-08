Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id D48D16B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 13:32:41 -0400 (EDT)
Received: by igxx6 with SMTP id x6so22048629igx.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 10:32:41 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id e36si3848238ioj.101.2015.09.08.10.32.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 10:32:41 -0700 (PDT)
Date: Tue, 8 Sep 2015 12:32:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
In-Reply-To: <20150905131825.6c04837d@redhat.com>
Message-ID: <alpine.DEB.2.11.1509081228100.26148@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <55E9DE51.7090109@gmail.com> <alpine.DEB.2.11.1509041354560.993@east.gentwo.org> <55EA0172.2040505@gmail.com> <alpine.DEB.2.11.1509041844190.2499@east.gentwo.org>
 <20150905131825.6c04837d@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com

On Sat, 5 Sep 2015, Jesper Dangaard Brouer wrote:

> The double_cmpxchg without lock prefix still cost 9 cycles, which is
> very fast but still a cost (add approx 19 cycles for a lock prefix).
>
> It is slower than local_irq_disable + local_irq_enable that only cost
> 7 cycles, which the bulking call uses.  (That is the reason bulk calls
> with 1 object can almost compete with fastpath).

Hmmm... Guess we need to come up with distinct version of kmalloc() for
irq and non irq contexts to take advantage of that . Most at non irq
context anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
