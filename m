Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 430AA6B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:49:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f49so10131692wrf.5
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 13:49:43 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o62si9622108wrc.80.2017.06.20.13.49.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 20 Jun 2017 13:49:42 -0700 (PDT)
Date: Tue, 20 Jun 2017 22:49:31 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v7 06/36] x86/mm: Add Secure Memory Encryption (SME)
 support
In-Reply-To: <20170616185054.18967.52228.stgit@tlendack-t1.amdoffice.net>
Message-ID: <alpine.DEB.2.20.1706202244480.2157@nanos>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net> <20170616185054.18967.52228.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?ISO-8859-2?Q?Radim_Kr=E8m=E1=F8?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, 16 Jun 2017, Tom Lendacky wrote:
>  
> +config ARCH_HAS_MEM_ENCRYPT
> +	def_bool y
> +	depends on X86

That one is silly. The config switch is in the x86 KConfig file, so X86 is
on. If you intended to move this to some generic place outside of
x86/Kconfig then this should be

config ARCH_HAS_MEM_ENCRYPT
	bool

and x86/Kconfig should have

    	select ARCH_HAS_MEM_ENCRYPT

and that should be selected by AMD_MEM_ENCRYPT

> +config AMD_MEM_ENCRYPT
> +	bool "AMD Secure Memory Encryption (SME) support"
> +	depends on X86_64 && CPU_SUP_AMD
> +	---help---
> +	  Say yes to enable support for the encryption of system memory.
> +	  This requires an AMD processor that supports Secure Memory
> +	  Encryption (SME).

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
