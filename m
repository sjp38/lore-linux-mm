Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7486B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 03:54:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p2so4544161pfk.13
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:54:59 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id bd7si1546530plb.577.2017.11.02.00.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 00:54:58 -0700 (PDT)
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D7A562193A
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:54:57 +0000 (UTC)
Received: by mail-io0-f179.google.com with SMTP id i38so11901184iod.2
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:54:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrUFddZwQmB9OBzbS-RObg_tU8CA70aEB4n+MG15yYLQRA@mail.gmail.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com> <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
 <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com> <CA+55aFxssHiO4f52UUCPXoxx+NOu5Epf6HhwsjUH8Ua+BP6Y=A@mail.gmail.com>
 <5005a38e-4dbf-d302-9a82-97c92d0f8f07@linux.intel.com> <CA+55aFzQ3cFin78_BcU8d1u1-kJugQh9c0PRJuDjXPf3Z75+Mw@mail.gmail.com>
 <CALCETrX4bxhLWeaTYPWQ8EdNscfUmWeUi6gfDuADqZtUvM01cA@mail.gmail.com> <CALCETrUFddZwQmB9OBzbS-RObg_tU8CA70aEB4n+MG15yYLQRA@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 2 Nov 2017 00:54:36 -0700
Message-ID: <CALCETrWBcEp+5iFPqP=V740CmZOBQ9P_+9h57G9tEUiJfvnLJw@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On Thu, Nov 2, 2017 at 12:32 AM, Andy Lutomirski <luto@kernel.org> wrote:
> On Wed, Nov 1, 2017 at 1:33 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> On Wed, Nov 1, 2017 at 12:05 PM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>>> On Wed, Nov 1, 2017 at 11:46 AM, Dave Hansen
>>> <dave.hansen@linux.intel.com> wrote:
>>>>
>>>> The vmalloc()'d stacks definitely need the page table walk.
>>>
>>> Ugh, yes. Nasty.
>>>
>>> Andy at some point mentioned a per-cpu initial stack trampoline thing
>>> for his exception patches, but I'm not sure he actually ever did that.
>>>
>>> Andy?
>>
>> I'm going to push it to kernel.org very shortly (like twenty minutes
>> maybe).  Then the 0day bot can chew on it.  With the proposed LDT
>> rework, we don't need to do any of dynamic mapping stuff, I think.
>
> FWIW, I pushed all but the actual stack switching part.  Something
> broke in the rebase and it doesn't boot right now :(

Okay, that was embarrassing.  The rebase error was, drumroll please, I
forgot one of the patches.  Sigh.

It's here:

https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/entry_consolidation

The last few patches are terminally ugly.  I'll clean them up shortly
and email them out.  That being said, unless there's a showstopper
bug, this should be a fine base for Dave's development.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
