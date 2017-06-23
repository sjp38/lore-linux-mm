Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D13A6B03C5
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:10:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so11003216wrc.8
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 02:10:13 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id y21si2366872wra.31.2017.06.23.02.10.11
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 02:10:12 -0700 (PDT)
Date: Fri, 23 Jun 2017 11:09:57 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 32/36] xen/x86: Remove SME feature in PV guests
Message-ID: <20170623090957.yb2x225f4ok4w5qu@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185554.18967.82909.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185554.18967.82909.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:55:54PM -0500, Tom Lendacky wrote:
> Xen does not currently support SME for PV guests. Clear the SME cpu

nitpick: s/cpu/CPU/

> capability in order to avoid any ambiguity.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/xen/enlighten_pv.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/x86/xen/enlighten_pv.c b/arch/x86/xen/enlighten_pv.c
> index f33eef4..e6ecf42 100644
> --- a/arch/x86/xen/enlighten_pv.c
> +++ b/arch/x86/xen/enlighten_pv.c
> @@ -294,6 +294,7 @@ static void __init xen_init_capabilities(void)
>  	setup_clear_cpu_cap(X86_FEATURE_MTRR);
>  	setup_clear_cpu_cap(X86_FEATURE_ACC);
>  	setup_clear_cpu_cap(X86_FEATURE_X2APIC);
> +	setup_clear_cpu_cap(X86_FEATURE_SME);
>  
>  	if (!xen_initial_domain())
>  		setup_clear_cpu_cap(X86_FEATURE_ACPI);

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
