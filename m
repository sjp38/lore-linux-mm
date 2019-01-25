Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2A88E00D7
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 14:30:08 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a23so8367151pfo.2
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 11:30:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m63si27890227pld.132.2019.01.25.11.30.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 25 Jan 2019 11:30:07 -0800 (PST)
Date: Fri, 25 Jan 2019 11:30:04 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Prevent mapping slab pages to userspace
Message-ID: <20190125193004.GA21155@bombadil.infradead.org>
References: <20190125173827.2658-1-willy@infradead.org>
 <CAGXu5jJ=yHXC_S_o6V4QQ+DCV4w2T-tw_BiUXDAW2a8rZDhZJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJ=yHXC_S_o6V4QQ+DCV4w2T-tw_BiUXDAW2a8rZDhZJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Michael Ellerman <mpe@ellerman.id.au>

On Sat, Jan 26, 2019 at 07:44:40AM +1300, Kees Cook wrote:
> > -       if (PageAnon(page))
> > +       if (PageAnon(page) || PageSlab(page))
> 
> Are there other types that should not get mapped? (Or better yet, is
> there a whitelist of those that are okay to be mapped?)

Funny you should ask; I think the next patch in this series looks like this:

-       if (PageAnon(page) || PageSlab(page))
+       if (PageAnon(page) || PageSlab(page) || page_has_type(page))

but let's see if there's something I've overlooked with this patch.
