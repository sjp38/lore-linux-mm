Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D68726B06BF
	for <linux-mm@kvack.org>; Fri, 18 May 2018 22:34:02 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q8-v6so6713888ioh.7
        for <linux-mm@kvack.org>; Fri, 18 May 2018 19:34:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9-v6sor5538323ioe.112.2018.05.18.19.34.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 19:34:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJwJo6YNqEBxbnJURL-+p_3S9rMBmJHNfE+WqwUF5nVkpRZ3nw@mail.gmail.com>
References: <20180517233510.24996-1-dima@arista.com> <1526600442.28243.39.camel@arista.com>
 <CALCETrUDX=4FHU0e8SZ9Rr_AnAes+5jjzKCrrVmS1mddHQyeVQ@mail.gmail.com>
 <CAJwJo6ZwEZiQYDQqLkfP0+mRgmc+X=H02M=fFZZykWN4A3s-FQ@mail.gmail.com>
 <CALCETrXV1Dnpms2_naBsY=pwFOFtBs4gWVpobHivbzJA=4GR_A@mail.gmail.com>
 <1526696547.13166.6.camel@arista.com> <CAJwJo6YNqEBxbnJURL-+p_3S9rMBmJHNfE+WqwUF5nVkpRZ3nw@mail.gmail.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Sat, 19 May 2018 03:33:41 +0100
Message-ID: <CAJwJo6YRw4Lkme5XNjhx-t+n11rtNO5z=0w4c-W5Td6TKmapOg@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Drop TS_COMPAT on 64-bit exec() syscall
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dima@arista.com>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, izbyshev@ispras.ru, Alexander Monakov <amonakov@ispras.ru>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, stable <stable@vger.kernel.org>

2018-05-19 3:25 GMT+01:00 Dmitry Safonov <0x7f454c46@gmail.com>:
>> Here is the function:
>> 0000000000400842 <call32_from_64>:
>>   400842:       53                      push   %rbx
>>   400843:       55                      push   %rbp
>>   400844:       41 54                   push   %r12
>>   400846:       41 55                   push   %r13
>>   400848:       41 56                   push   %r14
>>   40084a:       41 57                   push   %r15
>>   40084c:       9c                      pushfq
>>   40084d:       48 89 27                mov    %rsp,(%rdi)
>>   400850:       48 89 fc                mov    %rdi,%rsp
>>   400853:       6a 23                   pushq  $0x23
>>   400855:       68 5c 08 40 00          pushq  $0x40085c
>>   40085a:       48 cb                   lretq
>>   40085c:       ff d6                   callq  *%rsi
>>   40085e:       ea                      (bad)
>>   40085f:       65 08 40 00             or     %al,%gs:0x0(%rax)
>>   400863:       33 00                   xor    (%rax),%eax
>>   400865:       48 8b 24 24             mov    (%rsp),%rsp
>>   400869:       9d                      popfq
>>   40086a:       41 5f                   pop    %r15
>>   40086c:       41 5e                   pop    %r14
>>   40086e:       41 5d                   pop    %r13
>>   400870:       41 5c                   pop    %r12
>>   400872:       5d                      pop    %rbp
>>   400873:       5b                      pop    %rbx
>>   400874:       c3                      retq
>>   400875:       66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
>>   40087c:       00 00 00
>>   40087f:       90                      nop
>>
>> Looks like mov between registers caused it? The hell.
>
> Oh, it's not 400850, I missloked, but 40085a so lretq might case it.

But it's
002b:00000000417bafe8
USER_DS and sensible address, still no idea.

-- 
             Dmitry
