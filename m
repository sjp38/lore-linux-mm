Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id A3C956B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 10:47:52 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id j15so5001888qaq.37
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 07:47:52 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id 1si14146142qap.29.2014.06.03.07.47.51
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 07:47:52 -0700 (PDT)
Date: Tue, 3 Jun 2014 09:47:49 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 2/4] slub: Use new node functions
In-Reply-To: <20140603065756.GA31135@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1406030946130.13291@gentwo.org>
References: <20140530182753.191965442@linux.com> <20140530182801.436674724@linux.com> <20140602045933.GC17964@js1304-P5Q-DELUXE> <alpine.DEB.2.10.1406021025240.2987@gentwo.org> <20140603065756.GA31135@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Tue, 3 Jun 2014, Joonsoo Kim wrote:

> I think that We can also replace for_each_node_state() in
> free_kmem_cache_nodes(). What prevent it from being replaced?

There is the problem that we are assigning NULL to s->node[node] which
would not be covered so I thought I defer that for later when we deal with
corner cases.

> >
> > Here is a patch doing the additional modifications:
> >
>
> Seems good to me.

Ok, who is queuing the patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
