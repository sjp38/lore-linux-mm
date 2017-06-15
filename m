Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED56A6B02B4
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:23:29 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z22so11191960qtz.10
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 06:23:29 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0059.outbound.protection.outlook.com. [104.47.33.59])
        by mx.google.com with ESMTPS id t20si130113qtg.226.2017.06.15.06.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 06:23:28 -0700 (PDT)
Subject: Re: [PATCH v6 25/34] swiotlb: Add warnings for use of bounce buffers
 with SME
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191732.28645.42876.stgit@tlendack-t1.amdoffice.net>
 <20170614165052.fyn5t4gkq5leczcc@pd.tnic>
 <33d1debc-c684-cba1-7d95-493678f086d0@amd.com>
 <20170615090832.ncmq2kgom32cchhw@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <a6fb0334-42e4-a08f-ac95-f33c48b0711f@amd.com>
Date: Thu, 15 Jun 2017 08:23:17 -0500
MIME-Version: 1.0
In-Reply-To: <20170615090832.ncmq2kgom32cchhw@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 6/15/2017 4:08 AM, Borislav Petkov wrote:
> On Wed, Jun 14, 2017 at 02:49:02PM -0500, Tom Lendacky wrote:
>> I guess I don't need the sme_active() check since the second part of the
>> if statement can only ever be true if SME is active (since mask is
>> unsigned).
> 
> ... and you can define sme_me_mask as an u64 directly (it is that already,
> practically, as we don't do SME on 32-bit) and then get rid of the cast.

Let me look into that. There are so many places that are expecting an
unsigned long I'll have to see how that all works out from a build
perspective.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
