Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08DB46B03A9
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 10:09:35 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id w44so41573026otw.6
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 07:09:35 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0043.outbound.protection.outlook.com. [104.47.36.43])
        by mx.google.com with ESMTPS id x203si8275362oia.70.2017.02.21.07.09.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Feb 2017 07:09:34 -0800 (PST)
Subject: Re: [RFC PATCH v4 00/28] x86: Secure Memory Encryption (AMD)
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170218181209.xk5ut4g65f2fedzi@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <6e95ee26-a46d-e85b-ade7-c3973f0355e9@amd.com>
Date: Tue, 21 Feb 2017 09:09:27 -0600
MIME-Version: 1.0
In-Reply-To: <20170218181209.xk5ut4g65f2fedzi@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/18/2017 12:12 PM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:41:59AM -0600, Tom Lendacky wrote:
>>  create mode 100644 Documentation/x86/amd-memory-encryption.txt
>>  create mode 100644 arch/x86/include/asm/mem_encrypt.h
>>  create mode 100644 arch/x86/kernel/mem_encrypt_boot.S
>>  create mode 100644 arch/x86/kernel/mem_encrypt_init.c
>>  create mode 100644 arch/x86/mm/mem_encrypt.c
>
> I don't see anything standing in the way of merging those last two and
> having a single:
>
> arch/x86/kernel/mem_encrypt.c
>
> with all functionality in there with ifdeffery around it so
> that sme_encrypt_kernel() et all are still visible in the
> !CONFIG_AMD_MEM_ENCRYPT case.

Sounds good. I'll combine those two files.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
