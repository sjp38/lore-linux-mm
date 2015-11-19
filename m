Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AEAA76B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:40:53 -0500 (EST)
Received: by padhx2 with SMTP id hx2so91752273pad.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 12:40:53 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id sv10si656087pab.134.2015.11.19.12.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 12:40:52 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so91768133pac.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 12:40:52 -0800 (PST)
Date: Thu, 19 Nov 2015 12:40:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory exhaustion testing?
In-Reply-To: <20151117142120.494947f9@redhat.com>
Message-ID: <alpine.DEB.2.10.1511191239001.7151@chino.kir.corp.google.com>
References: <20151112215531.69ccec19@redhat.com> <alpine.DEB.2.10.1511131452130.6173@chino.kir.corp.google.com> <20151116152440.101ea77d@redhat.com> <20151117142120.494947f9@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue, 17 Nov 2015, Jesper Dangaard Brouer wrote:

> I did manage to provoke/test the error path in kmem_cache_alloc_bulk(),
> by using fault-injection framework "fail_page_alloc".
> 
> But was a little hard to trigger SLUB errors with this, because SLUB
> retries after a failure, and second call to alloc_pages() is done with
> lower order.
> 
> If order is lowered to zero, then should_fail_alloc_page() will skip it.
> And just lowering /sys/kernel/debug/fail_page_alloc/min-order=0 is not
> feasible as even fork starts to fail.  I managed to work-around this by
> using "space" setting.
> 
> Created a script to ease this tricky invocation:
>  https://github.com/netoptimizer/prototype-kernel/blob/master/tests/fault-inject/fail01_kmem_cache_alloc_bulk.sh
> 

Any chance you could proffer some of your scripts in the form of patches 
to the tools/testing directory?  Anything that can reliably trigger rarely 
executed code is always useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
