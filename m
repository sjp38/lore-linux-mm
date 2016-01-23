Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 236EF6B0009
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 13:51:22 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id z14so11541951igp.0
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 10:51:22 -0800 (PST)
Received: from mail-ig0-x241.google.com (mail-ig0-x241.google.com. [2607:f8b0:4001:c05::241])
        by mx.google.com with ESMTPS id d5si13932473igx.19.2016.01.23.10.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Jan 2016 10:51:21 -0800 (PST)
Received: by mail-ig0-x241.google.com with SMTP id o2so1591372iga.3
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 10:51:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <145354323486.16567.6251495688050187292.stgit@zurg>
References: <145354323486.16567.6251495688050187292.stgit@zurg>
Date: Sat, 23 Jan 2016 10:51:20 -0800
Message-ID: <CA+55aFwc4HF9E=54xA_z3KB_+Ka9rpMRoHQihGo0fP21JmN0cA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: warn about VmData over RLIMIT_DATA
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

On Sat, Jan 23, 2016 at 2:00 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> +       if ((flags & (VM_WRITE | VM_SHARED |
> +               (VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE &&
> +           mm->data_vm + npages > rlimit(RLIMIT_DATA) >> PAGE_SHIFT &&
> +           !WARN_ONCE(ignore_rlimit_data, "VmData %lu exceeds RLIMIT_DATA %lu",
> +                      (mm->data_vm + npages)<<PAGE_SHIFT, rlimit(RLIMIT_DATA)))
> +               return false;

This needs to be rewritten as an inline helper function or made
readable some other way.

It looks like line noise (or perl). That kind of code should not exist.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
