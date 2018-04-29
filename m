Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 653D46B000E
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 23:09:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s3so4968363pfh.0
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 20:09:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n6-v6si4914068plp.386.2018.04.28.20.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 28 Apr 2018 20:09:46 -0700 (PDT)
Date: Sat, 28 Apr 2018 20:09:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/3] linux-next: mm: hardening: Track genalloc allocations
Message-ID: <20180429030940.GA2541@bombadil.infradead.org>
References: <20180429024542.19475-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180429024542.19475-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, keescook@chromium.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org, labbott@redhat.com, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

On Sun, Apr 29, 2018 at 06:45:39AM +0400, Igor Stoppa wrote:
> This patchset was created as part of an older version of pmalloc, however
> it has value per-se, as it hardens the memory management for the generic
> allocator genalloc.
> 
> Genalloc does not currently track the size of the allocations it hands out.
> 
> Either by mistake, or due to an attack, it is possible that more memory
> than what was initially allocated is freed, leaving behind dangling
> pointers, ready for an use-after-free attack.

This is a good point.  It is worth hardening genalloc.
But I still don't like the cost of the bitmap.  I've been
reading about allocators and I found Bonwick's paper from 2001:
https://www.usenix.org/legacy/event/usenix01/full_papers/bonwick/bonwick.pdf
Section 4 describes the vmem allocator which would seem to have superior
performance and lower memory overhead than the current genalloc allocator,
never mind the hardened allocator.

Maybe there's been an advnace in resource allocator technology since
then that someone more familiar with CS research can point out.
