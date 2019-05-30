Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 181D7C072B1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 05:21:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA2DE2606C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 05:21:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nOfp6xAb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA2DE2606C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BBA76B027B; Thu, 30 May 2019 01:21:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46CA96B027D; Thu, 30 May 2019 01:21:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 335296B027E; Thu, 30 May 2019 01:21:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 125EE6B027B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 01:21:37 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id a23so1137336uas.17
        for <linux-mm@kvack.org>; Wed, 29 May 2019 22:21:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=N8Kqu9XhDk4eyHxJOCvnDVEeURLn9nIM7WXDv7rJ8RQ=;
        b=iHIbX/zAPqnnsIl9yqy4XPrvNN2zh1td0ysof4a0A+BCcqpKdOuN0N/o2ryj8WnH4U
         PuxGRnuxqAiNpHKpIBZ5rU/4WU1UQcpn5P+3sKT8cvc58e9iO4CSjUq5G8e9jeqop6p8
         JeVCBIR9TGTopx/iRoP0EchR/bVkQreSJrzApy8rvnpaNKSJ4lCNa7nw8e9GMbGBm2CD
         UILjgodzNxAvbgpSvSsMOGAXRkh/6zvlZEDcjhxbX6TU2FYktf1pmhwi6ttr8Sm/Dp/u
         vKKOTcJ/JjOH6xm/5pdb4bL+ChEpc5Txly/WRlmOS4djB4y+6ZTJXQDmeR8fs8L3R9HP
         x7oQ==
X-Gm-Message-State: APjAAAWnoH8Af2t9Q3VY+gbf2iRjo59y80eTSRqgf3dbI3GedIRbhJeZ
	EMdENBpTxiuNpTjNxqdwlsCffcHQKJUfR9psdo8yiXp1kakHXZ0PvuJlPOhnuSb1Hp+Lav89Zj0
	wnfggpZzvzdLOXL/M+/uZYkzPdlby2Zg/3GGvkgkz30uhDYjjvjEbV1l5WWBTNokSiQ==
X-Received: by 2002:a9f:3241:: with SMTP id y1mr886841uad.107.1559193696847;
        Wed, 29 May 2019 22:21:36 -0700 (PDT)
X-Received: by 2002:a9f:3241:: with SMTP id y1mr886831uad.107.1559193696375;
        Wed, 29 May 2019 22:21:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559193696; cv=none;
        d=google.com; s=arc-20160816;
        b=hxUY1t5+CpCxPZmRfhVEeVZwBP3HTGrMVMOV5fUm5laKtr5xKDdvKFWnR9PIM9UmmZ
         INUxV6l8GIKTagGGqQRTl+1z6rNYPsu4mISvmWLNP88qW0VD8SxXYMB80jw3TVWWjj2k
         Rxltva4xn1d33FCk0oc5CMP8gCP96UDRREqBE/i9p8QMRfbY2KnWbaFw5R3dCIe3WZ+8
         5jZnisVF5Ix0Kd7CCd0nmaOHxdy9aAwkZLQqDKvZKIpIUHZVgQ8lO0RMNoRfQzDP44R9
         DCeg+Nk3Ad8eBmiZoiGuFv8zK7L9y+QAHgKirmp7xjsxY6CIeD4rThkIQxVe3USrrb/i
         QUWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=N8Kqu9XhDk4eyHxJOCvnDVEeURLn9nIM7WXDv7rJ8RQ=;
        b=nhvTEvtchy++dbu12ppND/CGSZOsQqD6FPkY2HTRvGq9rzo4YdL76JgodnTHOgXnir
         TP/0/HUby41Wf/LyrvvsNIwKkyXRHJ+wy3pSUm9BoxyxNkALvDPxkAoVuvLnKlwSmpGn
         gUv9kxnSLhvh0n/yXrSXe5pGpd5T9T/XE+qOzOwFojvDPrC23I6NvXtSmCK7LfvNVlOY
         KeM6NQTTGh6x1j3bwKy5Hj02PbTh8HqP1SuHncWf4fX3RAmy6nqRGl4XQ8HLQERfDtHT
         65qbGmgaFfnRaYhNM0M0r0asshV11GC5RtmrHNuy3xSyYuswjkD/ZNOqwcqfFL/6zhHK
         JHxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nOfp6xAb;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m94sor753939uam.55.2019.05.29.22.21.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 22:21:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nOfp6xAb;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=N8Kqu9XhDk4eyHxJOCvnDVEeURLn9nIM7WXDv7rJ8RQ=;
        b=nOfp6xAb07c7fhTyEPViJQwkSTSfmWU/+klmqnkI9vWOtbvMhwszY6GFh6ufjBdu7g
         lpAq4QP0/Cufz4WaULPfWsua/GesqDG2HDvXk+NuUgfQhTvzxOdjgBniDIDnyRqY+4fc
         An+1RHMH7FDXq/dua0p+KM1Wew9m4jHnfDye9QEjShQPodvTTw4FEv0fxvn2El8x5kYE
         u7wJAhoUmz/cK93kAVTxiCQyxdHucxSw2pHYN8eV3W/n4u9DHZgjW8VbNnVhqIJV20Tq
         LXlRJ1w0Pc3GwDkob5jfDxszTaaQka77OPeVhsoOcZ8gO8m8HX1jb2INfcKGvedR7Q4R
         6U9g==
X-Google-Smtp-Source: APXvYqyBATh4neWGs74AqOJks4aL5K6flzPg8l6Xjw6Lgiu2KpqI9R909KkBWb43GnuU+RKAbdUiztE2zTdgEAImfno=
X-Received: by 2002:a9f:3241:: with SMTP id y1mr886824uad.107.1559193696177;
 Wed, 29 May 2019 22:21:36 -0700 (PDT)
MIME-Version: 1.0
References: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com> <20190529194852.GA23461@bombadil.infradead.org>
In-Reply-To: <20190529194852.GA23461@bombadil.infradead.org>
From: Dianzhang Chen <dianzhangchen0@gmail.com>
Date: Thu, 30 May 2019 13:21:23 +0800
Message-ID: <CAFbcbMAKOSjZzCumK3iGxBGL1Bjf+Qx==87F8A9xPBy5msj+Dw@mail.gmail.com>
Subject: Re: [PATCH] mm/slab_common.c: fix possible spectre-v1 in kmalloc_slab()
To: Matthew Wilcox <willy@infradead.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, 
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

thanks, i think your suggestion is ok.
in my previous method is easy to understand for spectre  logic,
but your suggestion is more sense to use of array_index_nospec.



On Thu, May 30, 2019 at 3:48 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, May 29, 2019 at 08:37:28PM +0800, Dianzhang Chen wrote:
> > The `size` in kmalloc_slab() is indirectly controlled by userspace via syscall: poll(defined in fs/select.c), hence leading to a potential exploitation of the Spectre variant 1 vulnerability.
> > The `size` can be controlled from: poll -> do_sys_poll -> kmalloc -> __kmalloc -> kmalloc_slab.
> >
> > Fix this by sanitizing `size` before using it to index size_index.
>
> I think it makes more sense to sanitize size in size_index_elem(),
> don't you?
>
>  static inline unsigned int size_index_elem(unsigned int bytes)
>  {
> -       return (bytes - 1) / 8;
> +       return array_index_nospec((bytes - 1) / 8, ARRAY_SIZE(size_index));
>  }
>
> (untested)

