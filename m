Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBE4A6B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 09:01:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w23-v6so994526pgv.1
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 06:01:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 77-v6si1289900pfh.332.2018.07.26.06.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Jul 2018 06:01:09 -0700 (PDT)
Date: Thu, 26 Jul 2018 06:01:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 7/7] docs/core-api: mm-api: add section about GFP flags
Message-ID: <20180726130106.GC3504@bombadil.infradead.org>
References: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1532607722-17079-8-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532607722-17079-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 26, 2018 at 03:22:02PM +0300, Mike Rapoport wrote:
> +Memory Allocation Controls
> +==========================

Perhaps call this section "Memory Allocation Flags" instead?

> +Linux provides a variety of APIs for memory allocation from direct
> +calls to page allocator through slab caches and vmalloc to allocators
> +of compressed memory. Although these allocators have different
> +semantics and are used in different circumstances, they all share the
> +GFP (get free page) flags that control behavior of each allocation
> +request.

While this isn't /wrong/, I think it might not be the most useful way
of explaining what the GFP flags are to someone who's just come across
them in some remote part of the kernel.  How about this paragraph instead?

  Functions which need to allocate memory often use GFP flags to express
  how that memory should be allocated.  The GFP acronym stands for "get
  free pages", the underlying memory allocation function.  Not every GFP
  flag is allowed to every function which may allocate memory.  Most
  users will want to use a plain ``GFP_KERNEL`` or ``GFP_ATOMIC``.

> +.. kernel-doc:: include/linux/gfp.h
> +   :doc: Page mobility and placement hints
> +
> +.. kernel-doc:: include/linux/gfp.h
> +   :doc: Watermark modifiers
> +
> +.. kernel-doc:: include/linux/gfp.h
> +   :doc: Reclaim modifiers
> +
> +.. kernel-doc:: include/linux/gfp.h
> +   :doc: Common combinations

Would it make more sense to put 'common combinations' first?
