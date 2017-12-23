Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D35F6B0281
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 02:31:57 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d4so14777736plr.8
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 23:31:57 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f19sor8904975plj.59.2017.12.22.23.31.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 23:31:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171223002505.593-1-aarcange@redhat.com>
References: <20171222222346.GB28786@zzz.localdomain> <20171223002505.593-1-aarcange@redhat.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 23 Dec 2017 08:31:35 +0100
Message-ID: <CACT4Y+av2MyJHHpPQLQ2EGyyW5vAe3i-U0pfVXshFm96t-1tBQ@mail.gmail.com>
Subject: Re: [PATCH 0/1] Re: kernel BUG at fs/userfaultfd.c:LINE!
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com

On Sat, Dec 23, 2017 at 1:25 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hello,
>
> Thanks for the CC, I'm temporarily very busy so if there's something
> urgent, safer to CC.

Hi,

syzbot uses get_maintainer.pl and for fs/userfaultfd.c you are not
there, so if you want to be CCed please add yourself to MAINTAINERS.


> This passed both testcases, the hard part was already done. I'm glad
> there was nothing wrong in the previous fix that had to be redone.
>
> Simply we forgot to undo the vma->vm_userfaultfd_ctx = NULL after
> aborting the new child uffd ctx, the original code of course didn't do
> that either.
>
> Having just seen this issue, this isn't very well tested.
>
> Thank you,
> Andrea
>
> Andrea Arcangeli (1):
>   userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK
>     fails
>
>  fs/userfaultfd.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)

The original report footer was stripped, so:

Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>

and we also need to tell syzbot about the fix with:

#syz fix:
userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK fails

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
