Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id D179F6B007B
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 12:08:31 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id r2so3271996igi.0
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:08:31 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id m10si3618346igx.38.2014.12.10.09.08.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 09:08:30 -0800 (PST)
Date: Wed, 10 Dec 2014 11:08:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
In-Reply-To: <CAOJsxLFEN_w7q6NvbxkH2KTujB9auLkQgskLnGtN9iBQ4hV9sw@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1412101107350.6291@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141210163033.717707217@linux.com> <CAOJsxLFEN_w7q6NvbxkH2KTujB9auLkQgskLnGtN9iBQ4hV9sw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 10 Dec 2014, Pekka Enberg wrote:

> > +static bool same_slab_page(struct kmem_cache *s, struct page *page, void *p)
>
> Why are you passing a pointer to struct kmem_cache here? You don't
> seem to use it.

True.
> > +{
> > +       long d = p - page->address;
> > +
> > +       return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
> > +}
>
> Can you elaborate on what this is doing? I don't really understand it.

Checks if the pointer points to the slab page. Also it tres to avoid
having to call compound_order needlessly. Not sure if that optimization is
worth it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
