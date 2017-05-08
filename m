Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E5FF76B03C3
	for <linux-mm@kvack.org>; Mon,  8 May 2017 09:20:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o7so72988529oia.14
        for <linux-mm@kvack.org>; Mon, 08 May 2017 06:20:24 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0086.outbound.protection.outlook.com. [104.47.41.86])
        by mx.google.com with ESMTPS id l59si4654453otl.106.2017.05.08.06.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 May 2017 06:20:23 -0700 (PDT)
Subject: Re: [PATCH v5 15/32] efi: Update efi_mem_type() to return an error
 rather than 0
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211900.10190.98158.stgit@tlendack-t1.amdoffice.net>
 <20170507171822.x7grrqg2tcvbv6j5@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <eb677bb2-ec20-c7a4-cd37-80f3f381981f@amd.com>
Date: Mon, 8 May 2017 08:20:14 -0500
MIME-Version: 1.0
In-Reply-To: <20170507171822.x7grrqg2tcvbv6j5@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/7/2017 12:18 PM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:19:00PM -0500, Tom Lendacky wrote:
>> The efi_mem_type() function currently returns a 0, which maps to
>> EFI_RESERVED_TYPE, if the function is unable to find a memmap entry for
>> the supplied physical address. Returning EFI_RESERVED_TYPE implies that
>> a memmap entry exists, when it doesn't.  Instead of returning 0, change
>> the function to return a negative error value when no memmap entry is
>> found.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>
> ...
>
>> diff --git a/include/linux/efi.h b/include/linux/efi.h
>> index cd768a1..a27bb3f 100644
>> --- a/include/linux/efi.h
>> +++ b/include/linux/efi.h
>> @@ -973,7 +973,7 @@ static inline void efi_esrt_init(void) { }
>>  extern int efi_config_parse_tables(void *config_tables, int count, int sz,
>>  				   efi_config_table_type_t *arch_tables);
>>  extern u64 efi_get_iobase (void);
>> -extern u32 efi_mem_type (unsigned long phys_addr);
>> +extern int efi_mem_type (unsigned long phys_addr);
>
> WARNING: space prohibited between function name and open parenthesis '('
> #101: FILE: include/linux/efi.h:976:
> +extern int efi_mem_type (unsigned long phys_addr);
>
> Please integrate scripts/checkpatch.pl in your patch creation workflow.
> Some of the warnings/errors *actually* make sense.

I do/did run scripts/checkpatch.pl against all my patches. In this case
I chose to keep the space in order to stay consistent with some of the
surrounding functions.  No problem though, I can remove the space.

Thanks,
Tom

>
> I know, the other function prototypes have a space too but that's not
> our coding style. Looks like this trickled in from ia64, from looking at
> arch/ia64/kernel/efi.c.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
