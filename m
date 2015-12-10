Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7B76E6B0255
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:10:27 -0500 (EST)
Received: by qgec40 with SMTP id c40so145497993qge.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:10:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f79si15213539qge.19.2015.12.10.07.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 07:10:23 -0800 (PST)
Date: Thu, 10 Dec 2015 16:10:18 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
Message-ID: <20151210161018.28cedb68@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1512091338240.7552@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul>
	<20151208161903.21945.33876.stgit@firesoul>
	<alpine.DEB.2.20.1512090945570.30894@east.gentwo.org>
	<20151209195325.68eaf314@redhat.com>
	<alpine.DEB.2.20.1512091338240.7552@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com

On Wed, 9 Dec 2015 13:41:07 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Wed, 9 Dec 2015, Jesper Dangaard Brouer wrote:
> 
> > I really like the idea of making it able to free kmalloc'ed objects.
> > But I hate to change the API again... (I do have a use-case in the
> > network stack where I could use this feature).
> 
> Now is the time to fix the API since its not that much in use yet if at
> all.

Lets start the naming thread/flame (while waiting for my flight ;-))

If we drop the "kmem_cache *s" parameter from kmem_cache_free_bulk(),
and also make it handle kmalloc'ed objects. Why should we name it
"kmem_cache_free_bulk"? ... what about naming it kfree_bulk() ???

Or should we keep the name to have a symmetric API
kmem_cache_{alloc,free}_bulk() call convention?

I'm undecided... 
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
