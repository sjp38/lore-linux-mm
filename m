Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 218696B0365
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 17:18:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e1so19472391pga.5
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 14:18:05 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a5si5289829pfe.10.2017.06.08.14.18.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 14:18:04 -0700 (PDT)
Subject: Re: [PATCH v6 10/34] x86, x86/mm, x86/xen, olpc: Use __va() against
 just the physical address in cr3
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
 <b15e8924-4069-b5fa-adb2-86c164b1dd36@oracle.com>
 <4a7376fb-abfc-8edd-42b7-38de461ac65e@amd.com>
 <67fe69ac-a213-8de3-db28-0e54bba95127@oracle.com>
 <fcb196c8-f1eb-a38c-336c-7bd3929b029e@amd.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <12c7e511-996d-cf60-3a3b-0be7b41bd85b@oracle.com>
Date: Thu, 8 Jun 2017 17:17:29 -0400
MIME-Version: 1.0
In-Reply-To: <fcb196c8-f1eb-a38c-336c-7bd3929b029e@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, xen-devel <xen-devel@lists.xen.org>

On 06/08/2017 05:02 PM, Tom Lendacky wrote:
> On 6/8/2017 3:51 PM, Boris Ostrovsky wrote:
>>
>>>
>>>> What may be needed is making sure X86_FEATURE_SME is not set for PV
>>>> guests.
>>>
>>> And that may be something that Xen will need to control through either
>>> CPUID or MSR support for the PV guests.
>>
>>
>> Only on newer versions of Xen. On earlier versions (2-3 years old) leaf
>> 0x80000007 is passed to the guest unchanged. And so is MSR_K8_SYSCFG.
>
> The SME feature is in leaf 0x8000001f, is that leaf passed to the guest
> unchanged?

Oh, I misread the patch where X86_FEATURE_SME is defined. Then all
versions, including the current one, pass it unchanged.

All that's needed is setup_clear_cpu_cap(X86_FEATURE_SME) in
xen_init_capabilities().


-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
