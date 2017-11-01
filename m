Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BCAC46B0069
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 16:33:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 76so3130245pfr.3
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 13:33:53 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 5si406793pls.167.2017.11.01.13.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 13:33:52 -0700 (PDT)
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6093821921
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 20:33:52 +0000 (UTC)
Received: by mail-io0-f174.google.com with SMTP id f20so8908144ioj.9
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 13:33:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzQ3cFin78_BcU8d1u1-kJugQh9c0PRJuDjXPf3Z75+Mw@mail.gmail.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com> <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
 <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com> <CA+55aFxssHiO4f52UUCPXoxx+NOu5Epf6HhwsjUH8Ua+BP6Y=A@mail.gmail.com>
 <5005a38e-4dbf-d302-9a82-97c92d0f8f07@linux.intel.com> <CA+55aFzQ3cFin78_BcU8d1u1-kJugQh9c0PRJuDjXPf3Z75+Mw@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 13:33:31 -0700
Message-ID: <CALCETrX4bxhLWeaTYPWQ8EdNscfUmWeUi6gfDuADqZtUvM01cA@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On Wed, Nov 1, 2017 at 12:05 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Nov 1, 2017 at 11:46 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>>
>> The vmalloc()'d stacks definitely need the page table walk.
>
> Ugh, yes. Nasty.
>
> Andy at some point mentioned a per-cpu initial stack trampoline thing
> for his exception patches, but I'm not sure he actually ever did that.
>
> Andy?

I'm going to push it to kernel.org very shortly (like twenty minutes
maybe).  Then the 0day bot can chew on it.  With the proposed LDT
rework, we don't need to do any of dynamic mapping stuff, I think.

>
>               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
