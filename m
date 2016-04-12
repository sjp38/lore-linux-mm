Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 10BA06B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 12:01:45 -0400 (EDT)
Received: by mail-io0-f174.google.com with SMTP id u185so34018552iod.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 09:01:45 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id 68si22799258iow.126.2016.04.12.09.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 09:01:44 -0700 (PDT)
Date: Tue, 12 Apr 2016 11:01:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC] Ideas for SLUB allocator
In-Reply-To: <20160412120215.000283c7@redhat.com>
Message-ID: <alpine.DEB.2.20.1604121057490.14315@east.gentwo.org>
References: <20160412120215.000283c7@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, js1304@gmail.com, lsf-pc@lists.linux-foundation.org

On Tue, 12 Apr 2016, Jesper Dangaard Brouer wrote:

> I have some ideas for improving SLUB allocator further, after my work
> on implementing the slab bulk APIs.  Maybe you can give me a small
> slot, I only have 7 guidance slides.  Or else I hope we/I can talk
> about these ideas in a hallway track with Christoph and others involved
> in slab development...

I will be there.

> I've already published the preliminary slides here:
>  http://people.netfilter.org/hawk/presentations/MM-summit2016/slab_mm_summit2016.odp

Re Autotuning: SLUB obj per page:
	SLUB can combine pages of different orders in a slab cache so this would
	be possible.

per CPU freelist per page:
	Could we drop the per cpu partial lists if this works?

Clearing memory:
	Could exploit the fact that the page is zero on alloc and also zap
	when no object in the page is in use?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
