Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id BAAC76B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 15:31:08 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so648318ied.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 12:31:08 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id 65si3377056iom.65.2015.04.09.12.31.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 12:31:08 -0700 (PDT)
Received: by iejt8 with SMTP id t8so537689iej.2
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 12:31:07 -0700 (PDT)
Date: Thu, 9 Apr 2015 12:31:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mempool: add missing include
In-Reply-To: <3302342.cNyRUGN06P@wuerfel>
Message-ID: <alpine.DEB.2.10.1504091230400.11370@chino.kir.corp.google.com>
References: <3302342.cNyRUGN06P@wuerfel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <a.ryabinin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Thu, 9 Apr 2015, Arnd Bergmann wrote:

> This is a fix^3 for the mempool poisoning patch, which introduces
> a compile-time error on some ARM randconfig builds:
> 
> mm/mempool.c: In function 'check_element':
> mm/mempool.c:65:16: error: implicit declaration of function 'kmap_atomic' [-Werror=implicit-function-declaration]
>    void *addr = kmap_atomic((struct page *)element);
> 
> The problem is clearly the missing declaration, and including
> linux/highmem.h fixes it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: a3db5a8463b0db ("mm, mempool: poison elements backed by page allocator fix fix")

Acked-by: David Rientjes <rientjes@google.com>

Thanks!  Can you confirm that this is because CONFIG_BLOCK is disabled and 
not something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
