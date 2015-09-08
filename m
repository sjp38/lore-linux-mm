Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6D96B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 11:54:58 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so127451646pac.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 08:54:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id oq6si6203985pab.88.2015.09.08.08.54.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 08:54:57 -0700 (PDT)
Date: Tue, 8 Sep 2015 17:54:51 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH mm] slab: implement bulking for SLAB allocator
Message-ID: <20150908175451.2ce83a0b@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1509081020510.25292@east.gentwo.org>
References: <20150908142147.22804.37717.stgit@devil>
	<alpine.DEB.2.11.1509081020510.25292@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, brouer@redhat.com

On Tue, 8 Sep 2015 10:22:32 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 8 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> > Also notice how well bulking maintains the performance when the bulk
> > size increases (which is a soar spot for the slub allocator).
> 
> Well you are not actually completing the free action in SLAB. This is
> simply queueing the item to be freed later. Also was this test done on a
> NUMA system? Alien caches at some point come into the picture.

This test was a single CPU benchmark with no congestion or concurrency.
But the code was compiled with CONFIG_NUMA=y.

I don't know the slAb code very well, but the kmem_cache_node->list_lock
looks like a scalability issue.  I guess that is what you are referring
to ;-)

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
