Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA8A6B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 12:29:24 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id c9so4165986qcz.19
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 09:29:24 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id x7si15532554qaj.186.2014.04.21.09.29.23
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 09:29:23 -0700 (PDT)
Date: Mon, 21 Apr 2014 11:29:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] how should we deal with dead memcgs' kmem caches?
In-Reply-To: <5353A3E3.4020302@parallels.com>
Message-ID: <alpine.DEB.2.10.1404211128450.28094@gentwo.org>
References: <5353A3E3.4020302@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, devel@openvz.org

On Sun, 20 Apr 2014, Vladimir Davydov wrote:

> * Way #1 - prevent dead kmem caches from caching slabs on free *
>
> We can modify sl[au]b implementation so that it won't cache any objects
> on free if the kmem cache belongs to a dead memcg. Then it'd be enough
> to drain per-cpu pools of all dead kmem caches on css offline - no new
> slabs will be added there on further frees, and the last object will go
> away along with the last slab.

You can call kmem_cache_shrink() to force slab allocators to drop cached
objects after a free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
