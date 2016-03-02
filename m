Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8245F828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:38:45 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id fz5so67952929obc.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:38:45 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id f10si4897466obt.98.2016.03.02.06.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 06:38:44 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id c203so61670975oia.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:38:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D6DC13.8060008@huawei.com>
References: <56D6DC13.8060008@huawei.com>
Date: Wed, 2 Mar 2016 23:38:44 +0900
Message-ID: <CAAmzW4OV4J_zGh2MSCqE0-x6Z_BopB+ucSVLV6kp53Cw4obkfg@mail.gmail.com>
Subject: Re: a question about slub in function __slab_free()
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

2016-03-02 21:26 GMT+09:00 Xishi Qiu <qiuxishi@huawei.com>:
> ___slab_alloc()
>         deactivate_slab()
>                 add_full(s, n, page);
> The page will be added to full list and the frozen is 0, right?
>
> __slab_free()
>         prior = page->freelist;  // prior is NULL
>         was_frozen = new.frozen;  // was_frozen is 0
>         ...
>                 /*
>                  * Slab was on no list before and will be
>                  * partially empty
>                  * We can defer the list move and instead
>                  * freeze it.
>                  */
>                 new.frozen = 1;
>         ...
>
> I don't understand why "Slab was on no list before"?

add_full() is defined only for CONFIG_SLUB_DEBUG.
And, actual add happens if slub_debug=u is enabled.
In other cases, fully used slab isn't attached on any list.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
