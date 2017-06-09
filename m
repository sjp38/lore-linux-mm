Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1CEB6B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 06:55:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c52so7712612wra.12
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 03:55:56 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id 20si1707085wmg.38.2017.06.09.03.55.55
        for <linux-mm@kvack.org>;
        Fri, 09 Jun 2017 03:55:55 -0700 (PDT)
Date: Fri, 9 Jun 2017 12:55:40 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 04/34] x86/CPU/AMD: Add the Secure Memory Encryption
 CPU feature
Message-ID: <20170609105540.jpkle2qja4kyin6i@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191353.28645.85058.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191353.28645.85058.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:13:53PM -0500, Tom Lendacky wrote:
> Update the CPU features to include identifying and reporting on the
> Secure Memory Encryption (SME) feature.  SME is identified by CPUID
> 0x8000001f, but requires BIOS support to enable it (set bit 23 of
> MSR_K8_SYSCFG).  Only show the SME feature as available if reported by
> CPUID and enabled by BIOS.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/cpufeatures.h |    1 +
>  arch/x86/include/asm/msr-index.h   |    2 ++
>  arch/x86/kernel/cpu/amd.c          |   13 +++++++++++++
>  arch/x86/kernel/cpu/scattered.c    |    1 +
>  4 files changed, 17 insertions(+)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
