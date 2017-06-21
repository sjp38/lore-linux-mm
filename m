Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 578726B03CE
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:55:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 4so13369520wrc.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:55:01 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id g24si13002344wrb.24.2017.06.21.02.54.59
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 02:55:00 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:54:48 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 24/36] x86, swiotlb: Add memory encryption support
Message-ID: <20170621095448.6c52kp2eves5uyzy@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185423.18967.19605.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185423.18967.19605.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:54:24PM -0500, Tom Lendacky wrote:
> Since DMA addresses will effectively look like 48-bit addresses when the
> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
> device performing the DMA does not support 48-bits. SWIOTLB will be
> initialized to create decrypted bounce buffers for use by these devices.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/dma-mapping.h |    5 ++-
>  arch/x86/include/asm/mem_encrypt.h |    5 +++
>  arch/x86/kernel/pci-dma.c          |   11 +++++--
>  arch/x86/kernel/pci-nommu.c        |    2 +
>  arch/x86/kernel/pci-swiotlb.c      |   15 +++++++++-
>  arch/x86/mm/mem_encrypt.c          |   22 +++++++++++++++
>  include/linux/swiotlb.h            |    1 +
>  init/main.c                        |   10 +++++++
>  lib/swiotlb.c                      |   54 +++++++++++++++++++++++++++++++-----
>  9 files changed, 108 insertions(+), 17 deletions(-)

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
