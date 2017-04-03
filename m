Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E80456B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 10:03:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d69so36417872ith.20
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 07:03:54 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id 14si14094923iol.163.2017.04.03.07.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 07:03:53 -0700 (PDT)
Date: Mon, 3 Apr 2017 09:03:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <874ly6gnuo.fsf@concordia.ellerman.id.au>
Message-ID: <alpine.DEB.2.20.1704030903010.4100@east.gentwo.org>
References: <20170331164028.GA118828@beast> <20170331143317.3865149a6b6112f0d1a63499@linux-foundation.org> <CAGXu5jK8RrHwa1Uv464=5+T5iBnhhx796CdLcJMAA88wi8bzaA@mail.gmail.com> <874ly6gnuo.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 3 Apr 2017, Michael Ellerman wrote:

> At least in slab.c it seems that would allow you to "free" an object
> from one kmem_cache onto the array_cache of another kmem_cache, which
> seems fishy. But maybe there's a check somewhere I'm missing?

kfree can be used to free any object from any slab cache.

kmem_cache_free() checks if the object belongs to the cache given.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
