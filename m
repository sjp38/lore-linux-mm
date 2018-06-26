Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9B2D6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 22:46:22 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id w15-v6so10467768otk.12
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 19:46:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2-v6sor182770oif.237.2018.06.25.19.46.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 19:46:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Tue, 26 Jun 2018 04:46:08 +0200
Message-ID: <CAG48ez2puLWrDDPg=ighCY+yxFoP-nN97MqVseqYabBad+eKmg@mail.gmail.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hjl.tools@gmail.com, vedvyas.shanbhogue@intel.com, ravi.v.shankar@intel.com, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue, Jun 26, 2018 at 4:45 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> This series introduces CET - Shadow stack
>
> At the high level, shadow stack is:
>
>         Allocated from a task's address space with vm_flags VM_SHSTK;
>         Its PTEs must be read-only and dirty;
>         Fixed sized, but the default size can be changed by sys admin.
>
> For a forked child, the shadow stack is duplicated when the next
> shadow stack access takes place.
>
> For a pthread child, a new shadow stack is allocated.
>
> The signal handler uses the same shadow stack as the main program.
>
> Yu-cheng Yu (10):
>   x86/cet: User-mode shadow stack support
>   x86/cet: Introduce WRUSS instruction
>   x86/cet: Signal handling for shadow stack
>   x86/cet: Handle thread shadow stack
>   x86/cet: ELF header parsing of Control Flow Enforcement
>   x86/cet: Add arch_prctl functions for shadow stack
>   mm: Prevent mprotect from changing shadow stack
>   mm: Prevent mremap of shadow stack
>   mm: Prevent madvise from changing shadow stack
>   mm: Prevent munmap and remap_file_pages of shadow stack

Shouldn't patches like these be CC'ed to linux-api@vger.kernel.org?
