Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADF3F6B02B8
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:33:16 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so9142610wmw.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 13:33:16 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id 74si4527339wmh.144.2016.11.15.13.33.15
        for <linux-mm@kvack.org>;
        Tue, 15 Nov 2016 13:33:15 -0800 (PST)
Date: Tue, 15 Nov 2016 22:33:12 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 04/20] x86: Handle reduction in physical address
 size with SME
Message-ID: <20161115213312.lrtejyv4x7nzvzsp@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003513.3280.12104.stgit@tlendack-t1.amdoffice.net>
 <20161115121035.GD24857@8bytes.org>
 <20161115121456.f4slpk4i2jl3e2ke@pd.tnic>
 <39da89c3-b89f-1d93-6af3-ea93cb750c45@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <39da89c3-b89f-1d93-6af3-ea93cb750c45@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Joerg Roedel <joro@8bytes.org>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Nov 15, 2016 at 03:22:45PM -0600, Tom Lendacky wrote:
> Hmmm... I still need the ebx value from the CPUID instruction to
> calculate the proper reduction in physical bits, so I'll still need
> to make the CPUID call.

        if (c->extended_cpuid_level >= 0x8000001f) {
                cpuid(0x8000001f, &eax, &ebx, &ecx, &edx);

		...

just like the rest of get_cpu_cap() :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
