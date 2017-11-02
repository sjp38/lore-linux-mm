Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F12476B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 03:32:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g6so5089830pgn.11
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:32:38 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f34si1609860ple.249.2017.11.02.00.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 00:32:37 -0700 (PDT)
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 87A7021923
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:32:37 +0000 (UTC)
Received: by mail-io0-f182.google.com with SMTP id 101so11788523ioj.3
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:32:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrX4bxhLWeaTYPWQ8EdNscfUmWeUi6gfDuADqZtUvM01cA@mail.gmail.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com> <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
 <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com> <CA+55aFxssHiO4f52UUCPXoxx+NOu5Epf6HhwsjUH8Ua+BP6Y=A@mail.gmail.com>
 <5005a38e-4dbf-d302-9a82-97c92d0f8f07@linux.intel.com> <CA+55aFzQ3cFin78_BcU8d1u1-kJugQh9c0PRJuDjXPf3Z75+Mw@mail.gmail.com>
 <CALCETrX4bxhLWeaTYPWQ8EdNscfUmWeUi6gfDuADqZtUvM01cA@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 2 Nov 2017 00:32:16 -0700
Message-ID: <CALCETrUFddZwQmB9OBzbS-RObg_tU8CA70aEB4n+MG15yYLQRA@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On Wed, Nov 1, 2017 at 1:33 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On Wed, Nov 1, 2017 at 12:05 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>> On Wed, Nov 1, 2017 at 11:46 AM, Dave Hansen
>> <dave.hansen@linux.intel.com> wrote:
>>>
>>> The vmalloc()'d stacks definitely need the page table walk.
>>
>> Ugh, yes. Nasty.
>>
>> Andy at some point mentioned a per-cpu initial stack trampoline thing
>> for his exception patches, but I'm not sure he actually ever did that.
>>
>> Andy?
>
> I'm going to push it to kernel.org very shortly (like twenty minutes
> maybe).  Then the 0day bot can chew on it.  With the proposed LDT
> rework, we don't need to do any of dynamic mapping stuff, I think.

FWIW, I pushed all but the actual stack switching part.  Something
broke in the rebase and it doesn't boot right now :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
