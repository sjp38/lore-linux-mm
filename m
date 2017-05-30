Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F99A6B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 13:47:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q27so106074206pfi.8
        for <linux-mm@kvack.org>; Tue, 30 May 2017 10:47:51 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0069.outbound.protection.outlook.com. [104.47.36.69])
        by mx.google.com with ESMTPS id z61si44649302plb.173.2017.05.30.10.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 May 2017 10:47:49 -0700 (PDT)
Subject: Re: [PATCH v5 17/32] x86/mm: Add support to access boot related data
 in the clear
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211921.10190.1537.stgit@tlendack-t1.amdoffice.net>
 <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
 <20170518195051.GA5651@codeblueprint.co.uk>
 <4c2ef3ba-2940-3330-d362-5b2b0d812c6f@amd.com>
 <20170526163517.nrweesvse24dszkz@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <900ee7c4-221a-f4d6-93c6-81dfc0612dbf@amd.com>
Date: Tue, 30 May 2017 12:47:30 -0500
MIME-Version: 1.0
In-Reply-To: <20170526163517.nrweesvse24dszkz@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Matt Fleming <matt@codeblueprint.co.uk>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On 5/26/2017 11:35 AM, Borislav Petkov wrote:
> On Fri, May 26, 2017 at 11:22:36AM -0500, Tom Lendacky wrote:
>> In addition to the same issue as efi.memmap.phys_map, efi_phys has
>> the __initdata attribute so it will be released/freed which will cause
>> problems in checks performed afterwards.
> 
> Sounds to me like we should drop the __initdata attr and prepare them
> much earlier for use by the SME code.

Probably something we can look at for a follow-on patch.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
