Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6373C6B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:16:45 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id y26-v6so3508661iob.19
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:16:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b62-v6sor1010862ith.6.2018.07.24.13.16.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 13:16:44 -0700 (PDT)
MIME-Version: 1.0
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
 <20180724121139.62570-2-kirill.shutemov@linux.intel.com> <20180724130308.bbd46afc3703af4c5e1d6868@linux-foundation.org>
In-Reply-To: <20180724130308.bbd46afc3703af4c5e1d6868@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 24 Jul 2018 13:16:33 -0700
Message-ID: <CA+55aFz1Vj3b2w-nOBdV5=WwsCYhSBprjPjGog6=_=q75Z5Z-w@mail.gmail.com>
Subject: Re: [PATCHv3 1/3] mm: Introduce vma_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jul 24, 2018 at 1:03 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
>
> I'd sleep better if this became a kmem_cache_alloc() and the memset
> was moved into vma_init().

Yeah, with the vma_init(), I guess the advantage of using
kmem_cache_zalloc() is pretty dubious.

Make it so.

        Linus
