Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 484C26B006A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 00:16:01 -0400 (EDT)
Received: by fxm24 with SMTP id 24so69582fxm.38
        for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:16:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1245210519.21602.16.camel@pasglop>
References: <1245210519.21602.16.camel@pasglop>
Date: Wed, 17 Jun 2009 07:16:28 +0300
Message-ID: <84144f020906162116v2d6f449fgc19aac69f19dd34f@mail.gmail.com>
Subject: Re: mm: Move pgtable_cache_init() earlier
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, linuxppc-dev list <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Wed, Jun 17, 2009 at 6:48 AM, Benjamin
Herrenschmidt<benh@kernel.crashing.org> wrote:
> Some architectures need to initialize SLAB caches to be able
> to allocate page tables. They do that from pgtable_cache_init()
> so the later should be called earlier now, best is before
> vmalloc_init().
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Looks good to me!

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
