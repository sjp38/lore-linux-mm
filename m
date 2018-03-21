Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0356B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:01:16 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id e53-v6so1074165otc.10
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:01:16 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id u69si3661158ioi.322.2018.03.21.11.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 11:01:15 -0700 (PDT)
Date: Wed, 21 Mar 2018 13:01:13 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <20180321174937.GF4780@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1803211300450.3706@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.DEB.2.20.1803211233290.3384@nuc-kabylake> <20180321174937.GF4780@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, 21 Mar 2018, Matthew Wilcox wrote:

> I don't know if that's a good idea.  That will contribute to fragmentation
> if the allocation is held onto for a short-to-medium length of time.
> If the allocation is for a very long period of time then those pages
> would have been unavailable anyway, but if the user of the tail pages
> holds them beyond the lifetime of the large allocation, then this is
> probably a bad tradeoff to make.
>
> I do see Mikulas' use case as interesting, I just don't know whether it's
> worth changing slab/slub to support it.  At first blush, other than the
> sheer size of the allocations, it's a good fit.

Well there are numerous page pool approaches already in the kernel. Maybe
there is a better fit with those?
