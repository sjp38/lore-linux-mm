Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 16A866B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 17:14:56 -0400 (EDT)
Received: by wizk4 with SMTP id k4so107185588wiz.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 14:14:55 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id i6si25978303wjs.169.2015.04.09.14.14.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 14:14:54 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mempool: add missing include
Date: Thu, 09 Apr 2015 23:14:14 +0200
Message-ID: <6079838.EgducKeYG3@wuerfel>
In-Reply-To: <alpine.DEB.2.10.1504091230400.11370@chino.kir.corp.google.com>
References: <3302342.cNyRUGN06P@wuerfel> <alpine.DEB.2.10.1504091230400.11370@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: David Rientjes <rientjes@google.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thursday 09 April 2015 12:31:05 David Rientjes wrote:
> On Thu, 9 Apr 2015, Arnd Bergmann wrote:
> 
> > This is a fix^3 for the mempool poisoning patch, which introduces
> > a compile-time error on some ARM randconfig builds:
> > 
> > mm/mempool.c: In function 'check_element':
> > mm/mempool.c:65:16: error: implicit declaration of function 'kmap_atomic' [-Werror=implicit-function-declaration]
> >    void *addr = kmap_atomic((struct page *)element);
> > 
> > The problem is clearly the missing declaration, and including
> > linux/highmem.h fixes it.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: a3db5a8463b0db ("mm, mempool: poison elements backed by page allocator fix fix")
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Thanks!  Can you confirm that this is because CONFIG_BLOCK is disabled and 
> not something else?

Unfortunately I've lost the information which build was responsible
for this error (normally I keep it, but my script failed here because the
same config introduced two new regressions). CONFIG_BLOCK sounds plausible
here.

If necessary, I can repeat the last few hundred builds without this
patch to find out what it was.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
