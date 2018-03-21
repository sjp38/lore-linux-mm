Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F41316B0005
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:58:41 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e4so5091828iof.7
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:58:41 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id 101si3728579ioj.180.2018.03.21.11.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 11:58:40 -0700 (PDT)
Date: Wed, 21 Mar 2018 13:58:39 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <20180321185558.GA18494@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1803211357480.14119@nuc-kabylake>
References: <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.DEB.2.20.1803211233290.3384@nuc-kabylake> <20180321174937.GF4780@bombadil.infradead.org>
 <alpine.LRH.2.02.1803211406180.26409@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211335240.13978@nuc-kabylake> <20180321185558.GA18494@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, 21 Mar 2018, Matthew Wilcox wrote:

> > Have a look at include/linux/mempool.h.
>
> That's not what mempool is for.  mempool is a cache of elements that were
> allocated from slab in the first place.  (OK, technically, you don't have
> to use slab as the allocator, but since there is no allocator that solves
> this problem, mempool doesn't solve the problem either!)

You can put the page allocator in there instead of a slab allocator.

> > But still the increased page order will get you into trouble with
> > fragmentation when the system runs for a long time. That is the reason we
> > try to limit the allocation sizes coming from the slab allocator.
>
> Right; he has a fallback already (vmalloc).  So ... let's just add the
> interface to allow slab caches to have their order tuned by users who
> really know what they're doing?

Ok thats trivial.
