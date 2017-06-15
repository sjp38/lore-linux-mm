Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EDB76B0315
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 05:56:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l43so194735wrl.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 02:56:09 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id 61si2742438wrm.255.2017.06.15.02.56.07
        for <linux-mm@kvack.org>;
        Thu, 15 Jun 2017 02:56:08 -0700 (PDT)
Date: Thu, 15 Jun 2017 11:55:59 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 29/34] kvm: x86: svm: Support Secure Memory Encryption
 within KVM
Message-ID: <20170615095559.mhf7amisrbzujvul@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191815.28645.9054.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191815.28645.9054.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:18:15PM -0500, Tom Lendacky wrote:
> Update the KVM support to work with SME. The VMCB has a number of fields
> where physical addresses are used and these addresses must contain the
> memory encryption mask in order to properly access the encrypted memory.
> Also, use the memory encryption mask when creating and using the nested
> page tables.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/kvm_host.h |    2 +-
>  arch/x86/kvm/mmu.c              |   12 ++++++++----
>  arch/x86/kvm/mmu.h              |    2 +-
>  arch/x86/kvm/svm.c              |   35 ++++++++++++++++++-----------------
>  arch/x86/kvm/vmx.c              |    3 ++-
>  arch/x86/kvm/x86.c              |    3 ++-
>  6 files changed, 32 insertions(+), 25 deletions(-)

Patches 27-29:

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
