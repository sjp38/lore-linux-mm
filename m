Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C95B76B0003
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 06:23:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f137so2202878wme.5
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 03:23:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 11sor5363141wrw.20.2018.04.07.03.23.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Apr 2018 03:23:04 -0700 (PDT)
Date: Sat, 7 Apr 2018 13:23:00 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: slab_ksize() and friends size_t -> unsigned int?
Message-ID: <20180407102300.GA2083@avx2>
References: <CAGXu5j+Ljf03iYAZY9A2YURJVB_0WvpyhDZHf1Sw_Fec-AfpOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+Ljf03iYAZY9A2YURJVB_0WvpyhDZHf1Sw_Fec-AfpOw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Linux-MM <linux-mm@kvack.org>

On Fri, Apr 06, 2018 at 10:06:31PM -0700, Kees Cook wrote:
> I saw all the other int and size_t conversions to unsigned int. What
> about ksize(), slab_ksize() and related functions too? It looks like
> many callers are already expecting unsigned int anyway...
> 
> net/core/skbuff.c:      unsigned int size = frag_size ? : ksize(data);
> 
> Though some are "int", ew:
> 
> int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>                      gfp_t gfp_mask)
> {
>         int i, osize = skb_end_offset(skb);
>         int size = osize + nhead + ntail;
> ...
>         size = SKB_WITH_OVERHEAD(ksize(data));

slab_ksize() can be changed.
As for ksize(). That path through page allocator is scary.

SLAB can be made unsigned int as well.
