Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0F5C6B000A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:51:49 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id g2so59553ioj.18
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:51:49 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id l185si7946254itb.72.2018.03.06.10.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:51:48 -0800 (PST)
Date: Tue, 6 Mar 2018 12:51:47 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 23/25] slub: make struct kmem_cache_order_objects::x
 unsigned int
In-Reply-To: <20180305200730.15812-23-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061248540.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-23-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Mon, 5 Mar 2018, Alexey Dobriyan wrote:

> struct kmem_cache_order_objects is for mixing order and number of objects,
> and orders aren't bit enough to warrant 64-bit width.
>
> Propagate unsignedness down so that everything fits.
>
> !!! Patch assumes that "PAGE_SIZE << order" doesn't overflow. !!!

PAGE_SIZE could be a couple of megs on some platforms (256 or so on
Itanium/PowerPC???) . So what are the worst case scenarios here?

I think both order and # object should fit in a 32 bit number.

A page with 256M size and 4 byte objects would have 64M objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
