Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC8396B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:05:51 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id n2so90858594obo.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:05:51 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0066.outbound.protection.outlook.com. [207.46.100.66])
        by mx.google.com with ESMTPS id 68si10335350iow.126.2016.04.27.08.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 08:05:50 -0700 (PDT)
Subject: Re: [RFC PATCH v1 01/18] x86: Set the write-protect cache mode for
 AMD processors
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225604.13567.55443.stgit@tlendack-t1.amdoffice.net>
 <CALCETrU9ozp1mBKG-P88cKRJRY5bifn2Ab__AZcn5b33n3j2cg@mail.gmail.com>
 <5720D066.7080409@amd.com>
 <CALCETrV+JzPZjrrqkhWSVfvKQt62Aq8NSW=ZvfdiAi8XKoLi8A@mail.gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5720D546.6050105@amd.com>
Date: Wed, 27 Apr 2016 10:05:42 -0500
MIME-Version: 1.0
In-Reply-To: <CALCETrV+JzPZjrrqkhWSVfvKQt62Aq8NSW=ZvfdiAi8XKoLi8A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 04/27/2016 09:47 AM, Andy Lutomirski wrote:
> On Wed, Apr 27, 2016 at 7:44 AM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
>> On 04/27/2016 09:33 AM, Andy Lutomirski wrote:
>>> On Tue, Apr 26, 2016 at 3:56 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
>>>> For AMD processors that support PAT, set the write-protect cache mode
>>>> (_PAGE_CACHE_MODE_WP) entry to the actual write-protect value (x05).
>>>
>>> What's the purpose of using the WP memory type?
>>
>> The WP memory type is used for encrypting or decrypting data "in place".
>> The use of the WP on the source data will prevent any of the source
>> data from being cached.  Refer to section 7.10.8 "Encrypt-in-Place" in
>> the AMD64 APM link provided in the cover letter.
>>
>> This memory type will be used in subsequent patches for this purpose.
> 
> OK.
> 
> Why AMD-only?  I thought Intel supported WP, too.

Just me being conservative. If there aren't any objections from the
Intel folks about it we can remove the vendor check and just set it.

Thanks,
Tom

> 
> --Andy
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
