Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1D16B000E
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:34:07 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 62so19307iow.16
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:34:07 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id m85si10887521iod.122.2018.03.06.10.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:34:06 -0800 (PST)
Date: Tue, 6 Mar 2018 12:34:05 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 05/25] slab: make create_boot_cache() work with 32-bit
 sizes
In-Reply-To: <20180305200730.15812-5-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061232190.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-5-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Mon, 5 Mar 2018, Alexey Dobriyan wrote:

> struct kmem_cache::size has always been "int", all those
> "size_t size" are fake.

They are useful since you typically pass sizeof( < whatever > ) as a
parameter to kmem_cache_create(). Passing those values onto other
functions internal to slab could use int.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
