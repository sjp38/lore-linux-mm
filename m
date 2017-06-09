Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 563F16B02F3
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 12:43:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g36so9264958wrg.4
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 09:43:26 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id r201si129200wmg.97.2017.06.09.09.43.24
        for <linux-mm@kvack.org>;
        Fri, 09 Jun 2017 09:43:25 -0700 (PDT)
Date: Fri, 9 Jun 2017 18:43:09 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 06/34] x86/mm: Add Secure Memory Encryption (SME)
 support
Message-ID: <20170609164309.45xgyzibdkzmdbde@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191416.28645.58145.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191416.28645.58145.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:14:16PM -0500, Tom Lendacky wrote:
> Add support for Secure Memory Encryption (SME). This initial support
> provides a Kconfig entry to build the SME support into the kernel and
> defines the memory encryption mask that will be used in subsequent
> patches to mark pages as encrypted.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/Kconfig                   |   22 ++++++++++++++++++++++
>  arch/x86/include/asm/mem_encrypt.h |   35 +++++++++++++++++++++++++++++++++++
>  arch/x86/mm/Makefile               |    1 +
>  arch/x86/mm/mem_encrypt.c          |   21 +++++++++++++++++++++
>  include/asm-generic/mem_encrypt.h  |   27 +++++++++++++++++++++++++++
>  include/linux/mem_encrypt.h        |   18 ++++++++++++++++++
>  6 files changed, 124 insertions(+)
>  create mode 100644 arch/x86/include/asm/mem_encrypt.h
>  create mode 100644 arch/x86/mm/mem_encrypt.c
>  create mode 100644 include/asm-generic/mem_encrypt.h
>  create mode 100644 include/linux/mem_encrypt.h

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
