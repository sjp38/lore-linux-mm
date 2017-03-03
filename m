Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0E626B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 11:59:35 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v66so41258251wrc.4
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 08:59:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x2si15562733wrc.9.2017.03.03.08.59.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 08:59:34 -0800 (PST)
Date: Fri, 3 Mar 2017 17:59:15 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 01/32] x86: Add the Secure Encrypted
 Virtualization CPU feature
Message-ID: <20170303165915.3233fx7wo74vsslx@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846752953.2349.17505492128445909591.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <148846752953.2349.17505492128445909591.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Mar 02, 2017 at 10:12:09AM -0500, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> Update the CPU features to include identifying and reporting on the
> Secure Encrypted Virtualization (SEV) feature.  SME is identified by
> CPUID 0x8000001f, but requires BIOS support to enable it (set bit 23 of
> MSR_K8_SYSCFG and set bit 0 of MSR_K7_HWCR).  Only show the SEV feature
> as available if reported by CPUID and enabled by BIOS.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/cpufeatures.h |    1 +
>  arch/x86/include/asm/msr-index.h   |    2 ++
>  arch/x86/kernel/cpu/amd.c          |   22 ++++++++++++++++++----
>  arch/x86/kernel/cpu/scattered.c    |    1 +
>  4 files changed, 22 insertions(+), 4 deletions(-)

So this patchset is not really ontop of Tom's patchset because this
patch doesn't apply. The reason is, Tom did the SME bit this way:

https://lkml.kernel.org/r/20170216154236.19244.7580.stgit@tlendack-t1.amdoffice.net

but it should've been in scattered.c.

> diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
> index cabda87..c3f58d9 100644
> --- a/arch/x86/kernel/cpu/scattered.c
> +++ b/arch/x86/kernel/cpu/scattered.c
> @@ -31,6 +31,7 @@ static const struct cpuid_bit cpuid_bits[] = {
>  	{ X86_FEATURE_CPB,		CPUID_EDX,  9, 0x80000007, 0 },
>  	{ X86_FEATURE_PROC_FEEDBACK,    CPUID_EDX, 11, 0x80000007, 0 },
>  	{ X86_FEATURE_SME,		CPUID_EAX,  0, 0x8000001f, 0 },
> +	{ X86_FEATURE_SEV,		CPUID_EAX,  1, 0x8000001f, 0 },
>  	{ 0, 0, 0, 0, 0 }

... and here it is in scattered.c, as it should be. So you've used an
older version of the patch, it seems.

Please sync with Tom to see whether he's reworked the v4 version of that
patch already. If yes, then you could send only the SME and SEV adding
patches as a reply to this message so that I can continue reviewing in
the meantime.

Thanks.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
