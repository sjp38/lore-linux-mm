Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 318A76B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 15:43:03 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 185so22122736itv.8
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 12:43:03 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 123si520035itx.78.2017.06.09.12.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 12:43:02 -0700 (PDT)
Subject: Re: [Xen-devel] [PATCH v6 10/34] x86, x86/mm, x86/xen, olpc: Use
 __va() against just the physical address in cr3
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
 <b15e8924-4069-b5fa-adb2-86c164b1dd36@oracle.com>
 <4a7376fb-abfc-8edd-42b7-38de461ac65e@amd.com>
 <67fe69ac-a213-8de3-db28-0e54bba95127@oracle.com>
 <fcb196c8-f1eb-a38c-336c-7bd3929b029e@amd.com>
 <12c7e511-996d-cf60-3a3b-0be7b41bd85b@oracle.com>
 <d37917b1-8e49-e8a8-b9ac-59491331640f@citrix.com>
 <9725c503-2e33-2365-87f5-f017e1cbe9b6@amd.com>
 <8e8eac45-95be-f1b5-6f44-f131d275f7bc@oracle.com>
 <33f20df0-bf71-bd9d-7a7e-4fb5e8793400@amd.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <d1931930-78d6-ebb1-755c-80bc88a397ed@oracle.com>
Date: Fri, 9 Jun 2017 15:42:24 -0400
MIME-Version: 1.0
In-Reply-To: <33f20df0-bf71-bd9d-7a7e-4fb5e8793400@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, Andrew Cooper <andrew.cooper3@citrix.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, xen-devel <xen-devel@lists.xen.org>, Paolo Bonzini <pbonzini@redhat.com>


>>
>> PV guests don't go through Linux x86 early boot code. They start at
>> xen_start_kernel() (well, xen-head.S:startup_xen(), really) and  merge
>> with baremetal path at x86_64_start_reservations() (for 64-bit).
>>
>
> Ok, I don't think anything needs to be done then. The sme_me_mask is set
> in sme_enable() which is only called from head_64.S. If the sme_me_mask
> isn't set then SME won't be active. The feature will just report the
> capability of the processor, but that doesn't mean it is active. If you
> still want the feature to be clobbered we can do that, though.

I'd prefer to explicitly clear to avoid any ambiguity.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
