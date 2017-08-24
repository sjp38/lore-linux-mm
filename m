Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58FC0440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 14:39:19 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r200so440569oie.0
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 11:39:19 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id q7si3777476oib.155.2017.08.24.11.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 11:39:13 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id k77so281531oib.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 11:39:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <43bcad51-b210-c1fa-c729-471fe008ba61@linux.intel.com>
References: <20170824175029.76040-1-ebiggers3@gmail.com> <43bcad51-b210-c1fa-c729-471fe008ba61@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Aug 2017 11:39:07 -0700
Message-ID: <CA+55aFw6zfaM=LubJnsERYVtaSdvNtGfFNRxeHvC=hahrh6wVA@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: fix use-after-free of ldt_struct
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Christoph Hellwig <hch@lst.de>, Denys Vlasenko <dvlasenk@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, stable <stable@vger.kernel.org>

Ingo,

 I'm assuming I get this through the -tip tree, which is where the
original commit 39a0526fb3f7 ("x86/mm: Factor out LDT init from
context init") came from.

                    Linus

On Thu, Aug 24, 2017 at 10:59 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 08/24/2017 10:50 AM, Eric Biggers wrote:
>> --- a/arch/x86/include/asm/mmu_context.h
>> +++ b/arch/x86/include/asm/mmu_context.h
>> @@ -148,9 +148,7 @@ static inline int init_new_context(struct task_struct *tsk,
>>               mm->context.execute_only_pkey = -1;
>>       }
>>       #endif
>> -     init_new_context_ldt(tsk, mm);
>> -
>> -     return 0;
>> +     return init_new_context_ldt(tsk, mm);
>>  }
>
> Sheesh.  That was silly.  Thanks for finding and fixing this!  Feel free
> to add my ack on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
