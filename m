Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id E2C326B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 11:33:46 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so11415752yha.7
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 08:33:46 -0800 (PST)
Received: from a9-50.smtp-out.amazonses.com (a9-50.smtp-out.amazonses.com. [54.240.9.50])
        by mx.google.com with ESMTP id n4si28987030qac.0.2013.12.04.08.33.44
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 08:33:45 -0800 (PST)
Date: Wed, 4 Dec 2013 16:33:43 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
In-Reply-To: <CAAmzW4PwLhMd61ksOktdg=rkj0xHsSGt2Wm_za2Adjh4+tss-g@mail.gmail.com>
Message-ID: <00000142be753b07-aa0e2354-6704-41f8-8e11-3c856a186af5-000000@email.amazonses.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org> <1381265890-11333-2-git-send-email-hannes@cmpxchg.org> <20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org> <20131204015218.GA19709@lge.com> <20131203180717.94c013d1.akpm@linux-foundation.org>
 <00000142be2f1de0-764bb035-adbc-4367-b2b4-bf05498510a6-000000@email.amazonses.com> <CAAmzW4PwLhMd61ksOktdg=rkj0xHsSGt2Wm_za2Adjh4+tss-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, Linux Memory Management List <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>

On Thu, 5 Dec 2013, Joonsoo Kim wrote:

> Now we have cpu partial slabs facility, so I think that slowpath isn't really
> slow. And it doesn't much increase the management overhead in the node
> partial lists, because of cpu partial slabs.

Well yes that may address some of the issues here.

> And larger frame may cause more slab_lock contention or cmpxchg contention
> if there are parallel freeings.
>
> But, I don't know which one is better. Is larger frame still better? :)

Could you run some tests to figure this one out? There are also
some situations in which we disable the per cpu partial pages though.
F.e. for low latency/realtime. I posted in kernel synthetic
benchmarks for slab a while back. That maybe something to start with.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
