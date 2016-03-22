Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8B186B0260
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:42:11 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j8so35601183lfd.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:42:11 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id u123si4756732wmu.54.2016.04.27.05.42.10
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 05:42:10 -0700 (PDT)
Date: Tue, 22 Mar 2016 14:01:50 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v1 02/18] x86: Secure Memory Encryption (SME) build
 enablement
Message-ID: <20160322130150.GB16528@xo-6d-61-c0.localdomain>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225614.13567.47487.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426225614.13567.47487.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue 2016-04-26 17:56:14, Tom Lendacky wrote:
> Provide the Kconfig support to build the SME support in the kernel.


Probably should go last in the series?

> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/Kconfig |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 7bb1574..13249b5 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1356,6 +1356,15 @@ config X86_DIRECT_GBPAGES
>  	  supports them), so don't confuse the user by printing
>  	  that we have them enabled.
>  
> +config AMD_MEM_ENCRYPT
> +	bool "Secure Memory Encryption support for AMD"
> +	depends on X86_64 && CPU_SUP_AMD
> +	---help---
> +	  Say yes to enable the encryption of system memory. This requires
> +	  an AMD processor that supports Secure Memory Encryption (SME).
> +	  The encryption of system memory is disabled by default but can be
> +	  enabled with the mem_encrypt=on command line option.
> +
>  # Common NUMA Features
>  config NUMA
>  	bool "Numa Memory Allocation and Scheduler Support"

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
