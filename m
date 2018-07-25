Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A74916B02A6
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:39:32 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u2-v6so5301636pls.7
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 05:39:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f3-v6sor3547814pgk.339.2018.07.25.05.39.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 05:39:31 -0700 (PDT)
Date: Wed, 25 Jul 2018 15:39:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 1/3] mm: Introduce vma_init()
Message-ID: <20180725123924.g2yvgie2iz2txmek@kshutemo-mobl1>
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
 <20180724121139.62570-2-kirill.shutemov@linux.intel.com>
 <20180724130308.bbd46afc3703af4c5e1d6868@linux-foundation.org>
 <CA+55aFz1Vj3b2w-nOBdV5=WwsCYhSBprjPjGog6=_=q75Z5Z-w@mail.gmail.com>
 <20180724134158.676dfa7a4da16adbab3b851c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724134158.676dfa7a4da16adbab3b851c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jul 24, 2018 at 01:41:58PM -0700, Andrew Morton wrote:
> On Tue, 24 Jul 2018 13:16:33 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Tue, Jul 24, 2018 at 1:03 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > >
> > > I'd sleep better if this became a kmem_cache_alloc() and the memset
> > > was moved into vma_init().
> > 
> > Yeah, with the vma_init(), I guess the advantage of using
> > kmem_cache_zalloc() is pretty dubious.
> > 
> > Make it so.
> > 
> 
> Did I get everything?

There are few more:

arch/arm64/include/asm/tlb.h:   struct vm_area_struct vma = { .vm_mm = tlb->mm, };
arch/arm64/mm/hugetlbpage.c:    struct vm_area_struct vma = { .vm_mm = mm };
arch/arm64/mm/hugetlbpage.c:    struct vm_area_struct vma = { .vm_mm = mm };

-- 
 Kirill A. Shutemov
