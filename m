Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6656B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:17:36 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id w10so21168488qtb.4
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:17:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r189sor18261634qkd.76.2017.11.27.02.17.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 02:17:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711241130540.19616@nuc-kabylake>
References: <20171123221628.8313-1-adobriyan@gmail.com> <20171123221628.8313-21-adobriyan@gmail.com>
 <alpine.DEB.2.20.1711241130540.19616@nuc-kabylake>
From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 27 Nov 2017 12:17:34 +0200
Message-ID: <CACVxJT_gi+3Wka5B-t6XGZ_XzostGf5sOj6mog570S-yofX4yA@mail.gmail.com>
Subject: Re: [PATCH 21/23] slub: make struct kmem_cache_order_objects::x
 unsigned int
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

On 11/24/17, Christopher Lameter <cl@linux.com> wrote:
> On Fri, 24 Nov 2017, Alexey Dobriyan wrote:
>
>> !!! Patch assumes that "PAGE_SIZE << order" doesn't overflow. !!!
>
> Check for that condition and do not allow creation of such caches?

It should be enforced by MAX_ORDER in slab_order() and
setup_slub_max_order().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
