Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id B3742900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 22:38:01 -0400 (EDT)
Received: by qcxw10 with SMTP id w10so25375366qcx.3
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 19:38:01 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id f185si6171890qhc.71.2015.06.04.19.38.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 19:38:00 -0700 (PDT)
Received: by qkoo18 with SMTP id o18so34142159qko.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 19:38:00 -0700 (PDT)
Message-ID: <1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [RFC PATCH] slub: RFC: Improving SLUB performance with 38% on
 NO-PREEMPT
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Jun 2015 19:37:57 -0700
In-Reply-To: <20150604103159.4744.75870.stgit@ivy>
References: <20150604103159.4744.75870.stgit@ivy>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, netdev@vger.kernel.org

On Thu, 2015-06-04 at 12:31 +0200, Jesper Dangaard Brouer wrote:
> This patch improves performance of SLUB allocator fastpath with 38% by
> avoiding the call to this_cpu_cmpxchg_double() for NO-PREEMPT kernels.
> 
> Reviewers please point out why this change is wrong, as such a large
> improvement should not be possible ;-)

I am not sure if anyone already answered, but the cmpxchg_double()
is needed to avoid the ABA problem.

This is the whole point using tid _and_ freelist

Preemption is not the only thing that could happen here, think of
interrupts.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
