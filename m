Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90CF36B0292
	for <linux-mm@kvack.org>; Tue, 30 May 2017 11:48:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c10so101702076pfg.10
        for <linux-mm@kvack.org>; Tue, 30 May 2017 08:48:47 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0073.outbound.protection.outlook.com. [104.47.40.73])
        by mx.google.com with ESMTPS id s9si14025053pge.240.2017.05.30.08.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 May 2017 08:48:46 -0700 (PDT)
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure Memory
 Encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <c29edaff-24f2-ee9b-4142-bdbf8c42083f@amd.com>
 <20170519113005.3f5kwzg4pgh7j6a5@pd.tnic>
 <20170519201651.dhayf2pwjlsnouz4@treble>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <1ac40d18-a8b2-94eb-35ed-c30768667be8@amd.com>
Date: Tue, 30 May 2017 10:48:27 -0500
MIME-Version: 1.0
In-Reply-To: <20170519201651.dhayf2pwjlsnouz4@treble>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>, Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/19/2017 3:16 PM, Josh Poimboeuf wrote:
> On Fri, May 19, 2017 at 01:30:05PM +0200, Borislav Petkov wrote:
>>> it is called so early. I can get past it by adding:
>>>
>>> CFLAGS_mem_encrypt.o := $(nostackp)
>>>
>>> in the arch/x86/mm/Makefile, but that obviously eliminates the support
>>> for the whole file.  Would it be better to split out the sme_enable()
>>> and other boot routines into a separate file or just apply the
>>> $(nostackp) to the whole file?
>>
>> Josh might have a better idea here... CCed.
> 
> I'm the stack validation guy, not the stack protection guy :-)
> 
> But there is a way to disable compiler options on a per-function basis
> with the gcc __optimize__ function attribute.  For example:
> 
>    __attribute__((__optimize__("no-stack-protector")))
> 

I'll look at doing that instead of removing the support for the whole
file.

Thanks,
Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
