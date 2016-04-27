Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBE376B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:48:04 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e63so91127067iod.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:48:04 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id s28si1942204otd.122.2016.04.27.07.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 07:48:04 -0700 (PDT)
Received: by mail-ob0-x22a.google.com with SMTP id n10so20936291obb.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:48:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5720D066.7080409@amd.com>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225604.13567.55443.stgit@tlendack-t1.amdoffice.net>
 <CALCETrU9ozp1mBKG-P88cKRJRY5bifn2Ab__AZcn5b33n3j2cg@mail.gmail.com> <5720D066.7080409@amd.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 27 Apr 2016 07:47:44 -0700
Message-ID: <CALCETrV+JzPZjrrqkhWSVfvKQt62Aq8NSW=ZvfdiAi8XKoLi8A@mail.gmail.com>
Subject: Re: [RFC PATCH v1 01/18] x86: Set the write-protect cache mode for
 AMD processors
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Apr 27, 2016 at 7:44 AM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
> On 04/27/2016 09:33 AM, Andy Lutomirski wrote:
>> On Tue, Apr 26, 2016 at 3:56 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
>>> For AMD processors that support PAT, set the write-protect cache mode
>>> (_PAGE_CACHE_MODE_WP) entry to the actual write-protect value (x05).
>>
>> What's the purpose of using the WP memory type?
>
> The WP memory type is used for encrypting or decrypting data "in place".
> The use of the WP on the source data will prevent any of the source
> data from being cached.  Refer to section 7.10.8 "Encrypt-in-Place" in
> the AMD64 APM link provided in the cover letter.
>
> This memory type will be used in subsequent patches for this purpose.

OK.

Why AMD-only?  I thought Intel supported WP, too.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
