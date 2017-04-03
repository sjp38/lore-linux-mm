Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B66A76B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 10:53:25 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 68so142761872pgj.23
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 07:53:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p15si14463783pgf.416.2017.04.03.07.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 07:53:24 -0700 (PDT)
Date: Mon, 3 Apr 2017 07:53:20 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170403145320.GD30811@bombadil.infradead.org>
References: <20170331164028.GA118828@beast>
 <20170331143317.3865149a6b6112f0d1a63499@linux-foundation.org>
 <CAGXu5jK8RrHwa1Uv464=5+T5iBnhhx796CdLcJMAA88wi8bzaA@mail.gmail.com>
 <874ly6gnuo.fsf@concordia.ellerman.id.au>
 <alpine.DEB.2.20.1704030903010.4100@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704030903010.4100@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 03, 2017 at 09:03:50AM -0500, Christoph Lameter wrote:
> On Mon, 3 Apr 2017, Michael Ellerman wrote:
> 
> > At least in slab.c it seems that would allow you to "free" an object
> > from one kmem_cache onto the array_cache of another kmem_cache, which
> > seems fishy. But maybe there's a check somewhere I'm missing?
> 
> kfree can be used to free any object from any slab cache.

Is that a guarantee?  There's some wording in the RCU free code that
seems to indicate we can't rely on that being true.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
