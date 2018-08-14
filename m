Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 33D466B000A
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 08:34:58 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w18-v6so12670579plp.3
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:34:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o1-v6si19283230pfe.259.2018.08.14.05.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 Aug 2018 05:34:57 -0700 (PDT)
Date: Tue, 14 Aug 2018 05:34:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC] usercopy: optimize stack check flow when the
Message-ID: <20180814123454.GA25328@bombadil.infradead.org>
References: <1534249051-56879-1-git-send-email-yuanxiaofeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1534249051-56879-1-git-send-email-yuanxiaofeng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiaofeng Yuan <yuanxiaofeng1@huawei.com>
Cc: keescook@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 14, 2018 at 08:17:31PM +0800, Xiaofeng Yuan wrote:
> The check_heap_object() checks the spanning multiple pages and slab.
> When the page-spanning test is disabled, the check_heap_object() is
> redundant for spanning multiple pages. However, the kernel stacks are
> multiple pages under certain conditions: CONFIG_ARCH_THREAD_STACK_ALLOCATOR
> is not defined and (THREAD_SIZE >= PAGE_SIZE). At this point, We can skip
> the check_heap_object() for kernel stacks to improve performance.
> Similarly, the virtually-mapped stack can skip check_heap_object() also,
> beacause virt_addr_valid() will return.

Why not just check_stack_object() first, then check_heap_object() second?
