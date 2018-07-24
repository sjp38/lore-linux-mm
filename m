Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7972C6B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:34:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v190-v6so10973321itc.0
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:34:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4-v6sor3914391iof.266.2018.07.24.10.34.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 10:34:06 -0700 (PDT)
MIME-Version: 1.0
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 24 Jul 2018 10:33:55 -0700
Message-ID: <CA+55aFwwY0UUYtyohfd-fnhpd=G3EYTtirfmQHXJ3n7C_PCSJA@mail.gmail.com>
Subject: Re: [PATCHv3 0/3] Fix crash due to vma_is_anonymous() false-positives
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jul 24, 2018 at 5:11 AM Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> Fix crash found by syzkaller.
>
> Build on top of Linus' changes in 4.18-rc6.
>
> Andrew, could you please drop mm-drop-unneeded-vm_ops-checks-v2.patch for
> now. Infiniband drivers have to be fixed first.

Ack, these look good to me.

We still need to have the rdma people fix up their vma mis-use, but
that's a related, but independent issue.

             Linus
