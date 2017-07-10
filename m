Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA7E444084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 12:55:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e3so118807008pfc.4
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:55:22 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0109.outbound.protection.outlook.com. [104.47.0.109])
        by mx.google.com with ESMTPS id f68si8204104pgc.17.2017.07.10.09.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 09:55:21 -0700 (PDT)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <20170525203334.867-8-kirill.shutemov@linux.intel.com>
 <20170526221059.o4kyt3ijdweurz6j@node.shutemov.name>
 <CACT4Y+YyFWg3fbj4ta3tSKoeBaw7hbL2YoBatAFiFB1_cMg9=Q@mail.gmail.com>
 <71e11033-f95c-887f-4e4e-351bcc3df71e@virtuozzo.com>
 <CACT4Y+bSTOeJtDDZVmkff=qqJFesA_b6uTG__EAn4AvDLw0jzQ@mail.gmail.com>
 <c4f11000-6138-c6ab-d075-2c4bd6a14943@virtuozzo.com>
 <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
 <bc95be68-8c68-2a45-c530-acbc6c90a231@virtuozzo.com>
 <20170710123346.7y3jnftqgpingim3@node.shutemov.name>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a3ed1e95-d1c1-9672-3010-ec06309f31cb@virtuozzo.com>
Date: Mon, 10 Jul 2017 19:57:00 +0300
MIME-Version: 1.0
In-Reply-To: <20170710123346.7y3jnftqgpingim3@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>



On 07/10/2017 03:33 PM, Kirill A. Shutemov wrote:

> 
> [Sorry for loong delay.]
> 
> The patch works for me for legacy boot. But it breaks EFI boot with
> 5-level paging. And I struggle to understand why.
> 
> What I see is many page faults at mm/kasan/kasan.c:758 --
> "DEFINE_ASAN_LOAD_STORE(4)". Handling one of them I get double-fault at
> arch/x86/kernel/head_64.S:298 -- "pushq %r14", which ends up with triple
> fault.
> 
> Any ideas?
> 
> If you want to play with this by yourself, qemu supports la57 -- use
> -cpu "qemu64,+la57".
> 

I'll have a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
