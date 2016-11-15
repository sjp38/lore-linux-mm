Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C53DF6B02B6
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:22:56 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id b202so107703965oii.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 13:22:56 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0081.outbound.protection.outlook.com. [104.47.34.81])
        by mx.google.com with ESMTPS id i131si12240875oib.236.2016.11.15.13.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 13:22:56 -0800 (PST)
Subject: Re: [RFC PATCH v3 04/20] x86: Handle reduction in physical address
 size with SME
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003513.3280.12104.stgit@tlendack-t1.amdoffice.net>
 <20161115121035.GD24857@8bytes.org> <20161115121456.f4slpk4i2jl3e2ke@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <39da89c3-b89f-1d93-6af3-ea93cb750c45@amd.com>
Date: Tue, 15 Nov 2016 15:22:45 -0600
MIME-Version: 1.0
In-Reply-To: <20161115121456.f4slpk4i2jl3e2ke@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Joerg Roedel <joro@8bytes.org>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/15/2016 6:14 AM, Borislav Petkov wrote:
> On Tue, Nov 15, 2016 at 01:10:35PM +0100, Joerg Roedel wrote:
>> Maybe add a comment here why you can't use cpu_has (yet).
> 
> So that could be alleviated by moving this function *after*
> init_scattered_cpuid_features(). Then you can simply do *cpu_has().
> 

Hmmm... I still need the ebx value from the CPUID instruction to
calculate the proper reduction in physical bits, so I'll still need
to make the CPUID call.

Thanks,
Tom

> Also, I'm not sure why we're checking CPUID for the SME feature when we
> have sme_get_me_mask() et al which have been setup much earlier...
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
