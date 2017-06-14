Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 04A536B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:39:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k71so4998560pgd.6
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:39:08 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0062.outbound.protection.outlook.com. [104.47.38.62])
        by mx.google.com with ESMTPS id a33si309916plc.382.2017.06.14.09.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 09:39:08 -0700 (PDT)
Subject: Re: [PATCH v6 23/34] x86, realmode: Decrypt trampoline area if memory
 encryption is active
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191709.28645.69034.stgit@tlendack-t1.amdoffice.net>
 <20170614162416.ksa54esy5ql7sjgz@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <dffd4702-9598-40ef-c9ad-ef970df13e32@amd.com>
Date: Wed, 14 Jun 2017 11:38:57 -0500
MIME-Version: 1.0
In-Reply-To: <20170614162416.ksa54esy5ql7sjgz@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 6/14/2017 11:24 AM, Borislav Petkov wrote:
> On Wed, Jun 07, 2017 at 02:17:09PM -0500, Tom Lendacky wrote:
>> When Secure Memory Encryption is enabled, the trampoline area must not
>> be encrypted. A CPU running in real mode will not be able to decrypt
>> memory that has been encrypted because it will not be able to use addresses
>> with the memory encryption mask.
>>
>> A recent change that added a new system_state value exposed a warning
>> issued by early_ioreamp() when the system_state was not SYSTEM_BOOTING.
>> At the stage where the trampoline area is decrypted, the system_state is
>> now SYSTEM_SCHEDULING. The check was changed to issue a warning if the
>> system_state is greater than or equal to SYSTEM_RUNNING.
> 
> This piece along with the hunk touching system_state absolutely needs to
> be a separate patch as it is unrelated.

Yup, will do.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
