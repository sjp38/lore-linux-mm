Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8943C6B03B9
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 14:30:36 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s69so6884634ioi.11
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 11:30:36 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id u125si2733056itc.22.2017.04.11.11.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 11:30:35 -0700 (PDT)
Date: Tue, 11 Apr 2017 13:30:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <20170331164028.GA118828@beast>
Message-ID: <alpine.DEB.2.20.1704111326370.6378@east.gentwo.org>
References: <20170331164028.GA118828@beast>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 31 Mar 2017, Kees Cook wrote:

> As found in PaX, this adds a cheap check on heap consistency, just to
> notice if things have gotten corrupted in the page lookup.

Ok this only affects kmem_cache_free() and not kfree(). For
kmem_cache_free() we already have a lot of stuff in the hotpath due to
cgruops. If you want this also for kfree() then we need a separate patch.

Also for kmem_cache_free(): Here we always have a slab cache and thus we
could check the flags that could modify what behavior we want.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
