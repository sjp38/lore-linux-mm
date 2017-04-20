Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1BEA6B0038
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 15:00:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z109so6552989wrb.12
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 12:00:18 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id p70si81390wmf.5.2017.04.20.12.00.17
        for <linux-mm@kvack.org>;
        Thu, 20 Apr 2017 12:00:17 -0700 (PDT)
Date: Thu, 20 Apr 2017 20:52:37 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 05/32] x86/CPU/AMD: Handle SME reduction in physical
 address size
Message-ID: <20170420185237.g5toqhgbemhcfu36@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211711.10190.30861.stgit@tlendack-t1.amdoffice.net>
 <20170420165922.j2inlwbchrs6senw@pd.tnic>
 <aaa52e93-5875-6033-e72f-8fc3de43ca3a@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <aaa52e93-5875-6033-e72f-8fc3de43ca3a@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Apr 20, 2017 at 12:29:20PM -0500, Tom Lendacky wrote:
> Hmmm... and actually if cpu_has(X86_FEATURE_SME) is true then it's a
> given that extended_cpuid_level >= 0x8000001f.  So this can be
> simplified to just:
> 
> 	if (cpu_has(c, X86_FEATURE_SME)) {
> 		... the rest of your suggestion (minus cpu_has()) ...

Cool, even better! :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
