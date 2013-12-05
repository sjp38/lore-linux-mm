Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 499BE6B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 03:42:10 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so25376287pbc.38
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 00:42:09 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id wh6si29466930pac.306.2013.12.05.00.42.07
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 00:42:08 -0800 (PST)
Date: Thu, 5 Dec 2013 17:44:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
Message-ID: <20131205084441.GA5561@lge.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
 <1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
 <20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org>
 <20131204015218.GA19709@lge.com>
 <20131203180717.94c013d1.akpm@linux-foundation.org>
 <00000142be2f1de0-764bb035-adbc-4367-b2b4-bf05498510a6-000000@email.amazonses.com>
 <CAAmzW4PwLhMd61ksOktdg=rkj0xHsSGt2Wm_za2Adjh4+tss-g@mail.gmail.com>
 <00000142be753b07-aa0e2354-6704-41f8-8e11-3c856a186af5-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142be753b07-aa0e2354-6704-41f8-8e11-3c856a186af5-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, Linux Memory Management List <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>

On Wed, Dec 04, 2013 at 04:33:43PM +0000, Christoph Lameter wrote:
> On Thu, 5 Dec 2013, Joonsoo Kim wrote:
> 
> > Now we have cpu partial slabs facility, so I think that slowpath isn't really
> > slow. And it doesn't much increase the management overhead in the node
> > partial lists, because of cpu partial slabs.
> 
> Well yes that may address some of the issues here.
> 
> > And larger frame may cause more slab_lock contention or cmpxchg contention
> > if there are parallel freeings.
> >
> > But, I don't know which one is better. Is larger frame still better? :)
> 
> Could you run some tests to figure this one out? There are also
> some situations in which we disable the per cpu partial pages though.
> F.e. for low latency/realtime. I posted in kernel synthetic
> benchmarks for slab a while back. That maybe something to start with.

I could try. But my trial would not figure this out, since my machine has
just 4 cores which normally cannot produce heavy contention.
Anyway, could you tell me where I can find your synthetic benchmarks for slab?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
