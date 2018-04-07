Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10EE86B0003
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 01:06:34 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id a31so2345356uaa.2
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 22:06:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m12sor4680820uah.74.2018.04.06.22.06.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 22:06:33 -0700 (PDT)
MIME-Version: 1.0
From: Kees Cook <keescook@chromium.org>
Date: Fri, 6 Apr 2018 22:06:31 -0700
Message-ID: <CAGXu5j+Ljf03iYAZY9A2YURJVB_0WvpyhDZHf1Sw_Fec-AfpOw@mail.gmail.com>
Subject: slab_ksize() and friends size_t -> unsigned int?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>

Hi,

I saw all the other int and size_t conversions to unsigned int. What
about ksize(), slab_ksize() and related functions too? It looks like
many callers are already expecting unsigned int anyway...

net/core/skbuff.c:      unsigned int size = frag_size ? : ksize(data);

Though some are "int", ew:

int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
                     gfp_t gfp_mask)
{
        int i, osize = skb_end_offset(skb);
        int size = osize + nhead + ntail;
...
        size = SKB_WITH_OVERHEAD(ksize(data));



-Kees

-- 
Kees Cook
Pixel Security
