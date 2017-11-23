Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCE66B0268
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 15:13:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c83so17719595pfj.11
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 12:13:08 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d11si16847610pgf.368.2017.11.23.12.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 12:13:07 -0800 (PST)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AF946219AB
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 20:13:06 +0000 (UTC)
Received: by mail-io0-f171.google.com with SMTP id d21so5408009ioe.7
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 12:13:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171123194210.GA2304@zzz.localdomain>
References: <20171123003455.275397F7@viggo.jf.intel.com> <20171123194210.GA2304@zzz.localdomain>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 23 Nov 2017 12:12:45 -0800
Message-ID: <CALCETrUWgqGMU=wF-=UAtEkHHRE5zdj+tDqwCZNJCGb4Yvvtyg@mail.gmail.com>
Subject: Re: [PATCH 09/23] x86, kaiser: map dynamically-allocated LDTs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, Nov 23, 2017 at 11:42 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
>> diff -puN arch/x86/kernel/ldt.c~kaiser-user-map-new-ldts arch/x86/kernel/ldt.c
>> --- a/arch/x86/kernel/ldt.c~kaiser-user-map-new-ldts  2017-11-22 15:45:49.059619739 -0800
>> +++ b/arch/x86/kernel/ldt.c   2017-11-22 15:45:49.062619739 -0800
>> @@ -11,6 +11,7 @@
> [...]
>> +     ret = kaiser_add_mapping((unsigned long)new_ldt->entries, alloc_size,
>> +                              __PAGE_KERNEL | _PAGE_GLOBAL);
>> +     if (ret) {
>> +             __free_ldt_struct(new_ldt);
>> +             return NULL;
>> +     }
>>       new_ldt->nr_entries = num_entries;
>>       return new_ldt;
>
> __free_ldt_struct() uses new_ldt->nr_entries, so new_ldt->nr_entries needs to be
> set earlier.
>

I would suggest just dropping this patch and forcing MODIFY_LDT off
when kaiser is on.  I'll fix it later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
