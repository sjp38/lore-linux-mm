Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCDB6B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 19:12:15 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so4765414igb.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 16:12:14 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id n81si155533ioe.61.2015.04.09.16.12.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 16:12:14 -0700 (PDT)
Received: by igbqf9 with SMTP id qf9so4717591igb.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 16:12:14 -0700 (PDT)
Date: Thu, 9 Apr 2015 16:12:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mempool: add missing include
In-Reply-To: <6079838.EgducKeYG3@wuerfel>
Message-ID: <alpine.DEB.2.10.1504091608410.21208@chino.kir.corp.google.com>
References: <3302342.cNyRUGN06P@wuerfel> <alpine.DEB.2.10.1504091230400.11370@chino.kir.corp.google.com> <6079838.EgducKeYG3@wuerfel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Andrey Ryabinin <a.ryabinin@samsung.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, 9 Apr 2015, Arnd Bergmann wrote:

> > > This is a fix^3 for the mempool poisoning patch, which introduces
> > > a compile-time error on some ARM randconfig builds:
> > > 
> > > mm/mempool.c: In function 'check_element':
> > > mm/mempool.c:65:16: error: implicit declaration of function 'kmap_atomic' [-Werror=implicit-function-declaration]
> > >    void *addr = kmap_atomic((struct page *)element);
> > > 
> > > The problem is clearly the missing declaration, and including
> > > linux/highmem.h fixes it.
> > > 
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > > Fixes: a3db5a8463b0db ("mm, mempool: poison elements backed by page allocator fix fix")
> > 
> > Acked-by: David Rientjes <rientjes@google.com>
> > 
> > Thanks!  Can you confirm that this is because CONFIG_BLOCK is disabled and 
> > not something else?
> 
> Unfortunately I've lost the information which build was responsible
> for this error (normally I keep it, but my script failed here because the
> same config introduced two new regressions). CONFIG_BLOCK sounds plausible
> here.
> 
> If necessary, I can repeat the last few hundred builds without this
> patch to find out what it was.
> 

Ok, thanks.  The only reason I ask is because if this is CONFIG_BLOCK then 
it shouldn't be arm specific and nothing else has reported it.  I'll do a 
randconfig loop with my arm cross-compiler and see if I can find any other 
issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
