Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A28786B025E
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 15:05:46 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 97so9949156iok.19
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 12:05:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h99sor655269ioi.200.2017.11.01.12.05.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 12:05:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5005a38e-4dbf-d302-9a82-97c92d0f8f07@linux.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com> <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
 <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com> <CA+55aFxssHiO4f52UUCPXoxx+NOu5Epf6HhwsjUH8Ua+BP6Y=A@mail.gmail.com>
 <5005a38e-4dbf-d302-9a82-97c92d0f8f07@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Nov 2017 12:05:44 -0700
Message-ID: <CA+55aFzQ3cFin78_BcU8d1u1-kJugQh9c0PRJuDjXPf3Z75+Mw@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On Wed, Nov 1, 2017 at 11:46 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> The vmalloc()'d stacks definitely need the page table walk.

Ugh, yes. Nasty.

Andy at some point mentioned a per-cpu initial stack trampoline thing
for his exception patches, but I'm not sure he actually ever did that.

Andy?

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
