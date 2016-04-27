Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9736B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:07:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so96273550pfb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:07:40 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q9si1188205paz.202.2016.04.27.10.07.39
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 10:07:39 -0700 (PDT)
Subject: Re: [RFC PATCH v1 02/18] x86: Secure Memory Encryption (SME) build
 enablement
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225614.13567.47487.stgit@tlendack-t1.amdoffice.net>
 <20160322130150.GB16528@xo-6d-61-c0.localdomain> <5720D810.9060602@amd.com>
 <20160427153010.GA7861@amd> <20160427154140.GK21011@pd.tnic>
 <20160427164137.GA11779@amd>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <5720F1D6.7020400@arm.com>
Date: Wed, 27 Apr 2016 18:07:34 +0100
MIME-Version: 1.0
In-Reply-To: <20160427164137.GA11779@amd>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Borislav Petkov <bp@alien8.de>
Cc: linux-efi@vger.kernel.org, kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, x86@kernel.org, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-arch@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, Paolo Bonzini <pbonzini@redhat.com>

On 27/04/16 17:41, Pavel Machek wrote:
> On Wed 2016-04-27 17:41:40, Borislav Petkov wrote:
>> On Wed, Apr 27, 2016 at 05:30:10PM +0200, Pavel Machek wrote:
>>> Doing it early will break bisect, right?
>>
>> How exactly? Please do tell.
>
> Hey look, SME slowed down 30% since being initially merged into
> kernel!

As opposed to "well, bisection shows these n+1 complicated changes are 
all fine and the crash is down to this Kconfig patch", presumably. I'm 
sure we all love spending a whole afternoon only to find that, right? :P

Robin.

> 									Pavel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
