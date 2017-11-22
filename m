Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A18F6B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 15:43:54 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i17so3694909wmb.7
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 12:43:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor9489598edj.10.2017.11.22.12.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 12:43:52 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <1511379391-988-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1511379391-988-1-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Wed, 22 Nov 2017 21:43:31 +0100
Message-ID: <CAKgNAkhtm0JqxeKXovoXPbApogMsGtMR=1td_NhT3AMv_Ot1Ng@mail.gmail.com>
Subject: Re: [PATCH v3 0/4] vm: add a syscall to map a process memory into a pipe
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Yossi Kuperman <yossiku@il.ibm.com>

Hi Mike,

On 22 November 2017 at 20:36, Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> From: Yossi Kuperman <yossiku@il.ibm.com>
>
> Hi,
>
> This patches introduces new process_vmsplice system call that combines
> functionality of process_vm_read and vmsplice.
>
> It allows to map the memory of another process into a pipe, similarly to
> what vmsplice does for its own address space.
>
> The patch 2/4 ("vm: add a syscall to map a process memory into a pipe")
> actually adds the new system call and provides its elaborate description.

Where is the man page for this new syscall?

Cheers,

Michael

> The patchset is against -mm tree.
>
> v3: minor refactoring to reduce code duplication
> v2: move this syscall under CONFIG_CROSS_MEMORY_ATTACH
>     give correct flags to get_user_pages_remote()
>
> Andrei Vagin (3):
>   vm: add a syscall to map a process memory into a pipe
>   x86: wire up the process_vmsplice syscall
>   test: add a test for the process_vmsplice syscall
>
> Mike Rapoport (1):
>   fs/splice: introduce pages_to_pipe helper
>
>  arch/x86/entry/syscalls/syscall_32.tbl             |   1 +
>  arch/x86/entry/syscalls/syscall_64.tbl             |   2 +
>  fs/splice.c                                        | 262 +++++++++++++++++++--
>  include/linux/compat.h                             |   3 +
>  include/linux/syscalls.h                           |   4 +
>  include/uapi/asm-generic/unistd.h                  |   5 +-
>  kernel/sys_ni.c                                    |   2 +
>  tools/testing/selftests/process_vmsplice/Makefile  |   5 +
>  .../process_vmsplice/process_vmsplice_test.c       | 188 +++++++++++++++
>  9 files changed, 450 insertions(+), 22 deletions(-)
>  create mode 100644 tools/testing/selftests/process_vmsplice/Makefile
>  create mode 100644 tools/testing/selftests/process_vmsplice/process_vmsplice_test.c
>
> --
> 2.7.4
>



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
