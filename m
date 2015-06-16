Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2E66B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:58:29 -0400 (EDT)
Received: by qcej3 with SMTP id j3so4317751qce.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:58:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e9si1006925qka.58.2015.06.16.06.58.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 06:58:28 -0700 (PDT)
Date: Tue, 16 Jun 2015 15:58:21 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Message-ID: <20150616155821.351a86a8@redhat.com>
In-Reply-To: <CAAmzW4P4kHW4NJv=BFXye4bENv1L7Tdyhuwio3rm5j-3y-tE-g@mail.gmail.com>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155256.18824.42651.stgit@devil>
	<20150616072328.GB13125@js1304-P5Q-DELUXE>
	<20150616112033.0b8bafb8@redhat.com>
	<CAAmzW4P4kHW4NJv=BFXye4bENv1L7Tdyhuwio3rm5j-3y-tE-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com


On Tue, 16 Jun 2015 21:00:39 +0900 Joonsoo Kim <js1304@gmail.com> wrote:

> > Okay, but Christoph choose to not support kmem_cache_debug() in patch2/7.
> >
> > Should we/I try to add kmem cache debugging support?
> 
> kmem_cache_debug() is the check for slab internal debugging feature.
> slab_free_hook() and others mentioned from me are also related to external
> debugging features like as kasan and kmemleak. So, even if
> debugged kmem_cache isn't supported by bulk API, external debugging
> feature should be supported.
> 
> > If adding these, then I would also need to add those on alloc path...
> 
> Yes, please.

I've added a patch 8 to my queue, that (tries to) implement this.
Currently trying to figure out how to "use" these debugging features,
so I activate that code path.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
