Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCD986B0397
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 06:40:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y19so10232005wrc.8
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 03:40:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si1369532wrs.75.2017.06.17.03.40.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Jun 2017 03:40:24 -0700 (PDT)
Subject: Re: [PATCH v7 32/36] xen/x86: Remove SME feature in PV guests
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185554.18967.82909.stgit@tlendack-t1.amdoffice.net>
From: Juergen Gross <jgross@suse.com>
Message-ID: <8dac5656-3d54-8b14-46ca-50072b507be3@suse.com>
Date: Sat, 17 Jun 2017 12:40:17 +0200
MIME-Version: 1.0
In-Reply-To: <20170616185554.18967.82909.stgit@tlendack-t1.amdoffice.net>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On 16/06/17 20:55, Tom Lendacky wrote:
> Xen does not currently support SME for PV guests. Clear the SME cpu
> capability in order to avoid any ambiguity.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

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
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
