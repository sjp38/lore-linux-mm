Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0836B0262
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 22:57:25 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j67so182763670oih.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:57:25 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 69si3130880ioz.248.2016.08.15.19.57.23
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 19:57:24 -0700 (PDT)
Date: Tue, 16 Aug 2016 12:03:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo
 stats
Message-ID: <20160816030314.GB16913@js1304-P5Q-DELUXE>
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
 <CAAmzW4On7FWc37fQJOsDQOEOVXqK3ue+uiB0ZOFM9R5e-Jj3WQ@mail.gmail.com>
 <alpine.DEB.2.20.1608050919410.27772@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1608050919410.27772@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Aug 05, 2016 at 09:21:56AM -0500, Christoph Lameter wrote:
> On Fri, 5 Aug 2016, Joonsoo Kim wrote:
> 
> > If above my comments are fixed, all counting would be done with
> > holding a lock. So, atomic definition isn't needed for the SLAB.
> 
> Ditto for slub. struct kmem_cache_node is alrady defined in mm/slab.h.
> Thus it is a common definition already and can be used by both.
> 
> Making nr_slabs and total_objects unsigned long would be great.

In SLUB, nr_slabs is manipulated without holding a lock so atomic
operation should be used.

Anyway, Aruna. Could you handle my comment?

Thank.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
