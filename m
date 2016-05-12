Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id C94D26B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 14:20:53 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id sq19so81662555igc.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 11:20:53 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0098.outbound.protection.outlook.com. [207.46.100.98])
        by mx.google.com with ESMTPS id w69si5668949oie.91.2016.05.12.11.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 12 May 2016 11:20:52 -0700 (PDT)
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160510134358.GR2839@codeblueprint.co.uk> <20160510135758.GA16783@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5734C97D.8060803@amd.com>
Date: Thu, 12 May 2016 13:20:45 -0500
MIME-Version: 1.0
In-Reply-To: <20160510135758.GA16783@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Matt Fleming <matt@codeblueprint.co.uk>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 05/10/2016 08:57 AM, Borislav Petkov wrote:
> On Tue, May 10, 2016 at 02:43:58PM +0100, Matt Fleming wrote:
>> Is it not possible to maintain some kind of kernel virtual address
>> mapping so memremap*() and friends can figure out when to twiddle the
>> mapping attributes and map with/without encryption?
> 
> I guess we can move the sme_* specific stuff one indirection layer
> below, i.e., in the *memremap() routines so that callers don't have to
> care... That should keep the churn down...
> 

We could do that, but we'll have to generate that list of addresses so
that it can be checked against the range being mapped.  Since this is
part of early memmap support searching that list every time might not be
too bad. I'll have to look into that and see what that looks like.

Thanks,
Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
