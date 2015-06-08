Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f45.google.com (mail-vn0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 89E6B6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 05:24:08 -0400 (EDT)
Received: by vnbf190 with SMTP id f190so16596565vnb.5
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 02:24:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id mq18si3850268vdb.57.2015.06.08.02.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 02:24:07 -0700 (PDT)
Date: Mon, 8 Jun 2015 11:23:59 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH] slub: RFC: Improving SLUB performance with 38% on
 NO-PREEMPT
Message-ID: <20150608112359.04a3750e@redhat.com>
In-Reply-To: <1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150604103159.4744.75870.stgit@ivy>
	<1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, netdev@vger.kernel.org, brouer@redhat.com

On Thu, 04 Jun 2015 19:37:57 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2015-06-04 at 12:31 +0200, Jesper Dangaard Brouer wrote:
> > This patch improves performance of SLUB allocator fastpath with 38% by
> > avoiding the call to this_cpu_cmpxchg_double() for NO-PREEMPT kernels.
> > 
> > Reviewers please point out why this change is wrong, as such a large
> > improvement should not be possible ;-)
> 
> I am not sure if anyone already answered, but the cmpxchg_double()
> is needed to avoid the ABA problem.
> 
> This is the whole point using tid _and_ freelist
> 
> Preemption is not the only thing that could happen here, think of
> interrupts.

Yes, I sort of already knew this.

My real question is if disabling local interrupts is enough to avoid this?

And, does local irq disabling also stop preemption?

Questions relate to this patch:
 http://ozlabs.org/~akpm/mmots/broken-out/slub-bulk-alloc-extract-objects-from-the-per-cpu-slab.patch

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
