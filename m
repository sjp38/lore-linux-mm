Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC7F6B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:24:19 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id m37so1959140iti.9
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:24:19 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id m3si10725678ioe.19.2018.03.06.10.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:24:18 -0800 (PST)
Date: Tue, 6 Mar 2018 12:24:17 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 02/25] slab: make kmalloc_index() return "unsigned int"
In-Reply-To: <20180305200730.15812-2-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061222550.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-2-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Mon, 5 Mar 2018, Alexey Dobriyan wrote:

> 3) in case of SLAB allocators, there are additional limitations
>    *) page->inuse, page->objects are only 16-/15-bit,
>    *) cache size was always 32-bit
>    *) slab orders are small, order 20 is needed to go 64-bit on x86_64
>       (PAGE_SIZE << order)

That changes with large base page size on power and ARM64 f.e. but then
we do not want to encourage larger allocations through slab anyways.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
