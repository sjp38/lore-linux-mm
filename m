Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D952C6B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 12:30:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v104so9219882wrb.6
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 09:30:22 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id j133si89237wmg.152.2017.06.09.09.30.19
        for <linux-mm@kvack.org>;
        Fri, 09 Jun 2017 09:30:20 -0700 (PDT)
Date: Fri, 9 Jun 2017 18:30:03 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 05/34] x86/CPU/AMD: Handle SME reduction in physical
 address size
Message-ID: <20170609163003.g2s6aqzkikt6nt4a@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191404.28645.41148.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191404.28645.41148.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:14:04PM -0500, Tom Lendacky wrote:
> When System Memory Encryption (SME) is enabled, the physical address
> space is reduced. Adjust the x86_phys_bits value to reflect this
> reduction.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/cpu/amd.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)

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
