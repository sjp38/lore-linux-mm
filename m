Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id EBB176B0069
	for <linux-mm@kvack.org>; Sun,  5 Oct 2014 13:15:55 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id hy4so2375093vcb.28
        for <linux-mm@kvack.org>; Sun, 05 Oct 2014 10:15:55 -0700 (PDT)
Received: from mail-vc0-x22d.google.com (mail-vc0-x22d.google.com [2607:f8b0:400c:c03::22d])
        by mx.google.com with ESMTPS id r9si6952680vcx.105.2014.10.05.10.15.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 05 Oct 2014 10:15:54 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id ij19so2322917vcb.4
        for <linux-mm@kvack.org>; Sun, 05 Oct 2014 10:15:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
Date: Sun, 5 Oct 2014 10:15:53 -0700
Message-ID: <CA+55aFx+n_n5wXBE7d+6cL-3ObUqNsJt7ZuuthOb+tmKZYeSyw@mail.gmail.com>
Subject: Re: [patch for-3.17] mm, thp: fix collapsing of hugepages on madvise
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Suleiman Souhlal <suleiman@google.com>, stable <stable@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sat, Oct 4, 2014 at 7:48 PM, David Rientjes <rientjes@google.com> wrote:
>
> This occurs because the madvise(2) handler for thp, hugepage_advise(),
> clears VM_NOHUGEPAGE on the stack and it isn't stored in vma->vm_flags
> until the final action of madvise_behavior().  This causes the
> khugepaged_enter_vma_merge() to be a no-op in hugepage_advise() when the
> vma had previously had VM_NOHUGEPAGE set.

So color me confused, and when I'm confused I don't apply patches. But
there's no "hugepage_advise()" in my source tree, and quite frankly, I
also don't like how you now separately pass in vm_flags that always
*should* be the same as vma->vm_flags.

Maybe this is against -mm, but it's marked for stable and sent to me,
so I'm piping up about my lack of applying this.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
