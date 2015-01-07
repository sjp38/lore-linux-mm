Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 545C96B0038
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 22:16:55 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id s7so1206855qap.0
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 19:16:55 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id u47si562032qge.5.2015.01.06.19.16.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 19:16:54 -0800 (PST)
Date: Tue, 6 Jan 2015 21:16:51 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME to
 file linux/slab.h
In-Reply-To: <CAC2pzGe9Q+19LpyFPwr8+TZ02XfCqwrQzsEsJA8WWB6XhuJyeQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1501062114240.5674@gentwo.org>
References: <CAC2pzGe9Q+19LpyFPwr8+TZ02XfCqwrQzsEsJA8WWB6XhuJyeQ@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bryton Lee <brytonlee01@gmail.com>
Cc: iamjoonsoo.kim@lge.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "vger.linux-kernel.cn" <kernel@vger.linux-kernel.cn>

On Wed, 7 Jan 2015, Bryton Lee wrote:

> move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME from file mm/slab_common.c
> to file linux/slab.h.
> let other kernel code create slab can use these flags.

This does not make sense. The fact that a slab has been merged is
available from a field in the kmem_cache structure (aliases).


These two macros are criteria for the slab allocators to perform merges.
The merge decision is the slab allocators decision and not the decision of
other kernel code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
