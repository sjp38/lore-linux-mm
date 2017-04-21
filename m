Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B01D46B037E
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 17:40:43 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a140so1666852ita.3
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:40:43 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0083.outbound.protection.outlook.com. [104.47.41.83])
        by mx.google.com with ESMTPS id v13si11331866plk.183.2017.04.21.14.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 14:40:42 -0700 (PDT)
Subject: Re: [PATCH v5 07/32] x86/mm: Add support to enable SME in early boot
 processing
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211735.10190.29562.stgit@tlendack-t1.amdoffice.net>
 <20170421145555.v3xeaijv3vjclsos@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <0b455224-f73e-d6f6-45c2-336178a89071@amd.com>
Date: Fri, 21 Apr 2017 16:40:29 -0500
MIME-Version: 1.0
In-Reply-To: <20170421145555.v3xeaijv3vjclsos@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 4/21/2017 9:55 AM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:17:35PM -0500, Tom Lendacky wrote:
>> Add support to the early boot code to use Secure Memory Encryption (SME).
>> Since the kernel has been loaded into memory in a decrypted state, support
>> is added to encrypt the kernel in place and update the early pagetables
>
> s/support is added to //

Done.

Thanks,
Tom

>
>> with the memory encryption mask so that new pagetable entries will use
>> memory encryption.
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
