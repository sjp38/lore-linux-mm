Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5546B6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:21:10 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 186so57413284itf.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:21:10 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0088.outbound.protection.outlook.com. [104.47.38.88])
        by mx.google.com with ESMTPS id c76si13391996oig.58.2016.09.14.07.20.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 07:20:56 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/20] mm: Access BOOT related data in the clear
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223738.29880.6909.stgit@tlendack-t1.amdoffice.net>
 <CALCETrUk2kRSzKfwhio6KV3iuYaSV2uxybd-e95kK3vY=yTSfg@mail.gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <e30ddb53-df6c-28ee-54fe-f3e52e515acb@amd.com>
Date: Wed, 14 Sep 2016 09:20:44 -0500
MIME-Version: 1.0
In-Reply-To: <CALCETrUk2kRSzKfwhio6KV3iuYaSV2uxybd-e95kK3vY=yTSfg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Matt Fleming <mfleming@suse.de>
Cc: kasan-dev <kasan-dev@googlegroups.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, iommu@lists.linux-foundation.org, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "H. Peter
 Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, kvm list <kvm@vger.kernel.org>

On 09/12/2016 11:55 AM, Andy Lutomirski wrote:
> On Aug 22, 2016 6:53 PM, "Tom Lendacky" <thomas.lendacky@amd.com> wrote:
>>
>> BOOT data (such as EFI related data) is not encyrpted when the system is
>> booted and needs to be accessed as non-encrypted.  Add support to the
>> early_memremap API to identify the type of data being accessed so that
>> the proper encryption attribute can be applied.  Currently, two types
>> of data are defined, KERNEL_DATA and BOOT_DATA.
> 
> What happens when you memremap boot services data outside of early
> boot?  Matt just added code that does this.
> 
> IMO this API is not so great.  It scatters a specialized consideration
> all over the place.  Could early_memremap not look up the PA to figure
> out what to do?

Yes, I could see if the PA falls outside of the kernel usable area and,
if so, remove the memory encryption attribute from the mapping (for both
early_memremap and memremap).

Let me look into that, I would prefer something along that line over
this change.

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
