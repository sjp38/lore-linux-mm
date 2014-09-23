Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 429336B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:22:11 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so7324842pdi.30
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 16:22:10 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id h9si23158737pat.157.2014.09.23.16.22.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 16:22:10 -0700 (PDT)
Date: Tue, 23 Sep 2014 18:22:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] mm, slab: initialize object alignment on cache
 creation
In-Reply-To: <alpine.DEB.2.02.1409231439190.22630@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1409231821050.32451@gentwo.org>
References: <20140923141940.e2d3840f31d0f8850b925cf6@linux-foundation.org> <alpine.DEB.2.02.1409231439190.22630@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, a.elovikov@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 23 Sep 2014, David Rientjes wrote:

> The proper alignment defaults to BYTES_PER_WORD and can be overridden by
> SLAB_RED_ZONE or the alignment specified by the caller.

Where does it default to BYTES_PER_WORD in __kmem_cache_create?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
