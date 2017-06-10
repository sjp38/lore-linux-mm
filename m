Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 339BC6B0292
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 11:56:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g76so13699415wrd.3
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 08:56:44 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id l125si2811369wmb.68.2017.06.10.08.56.42
        for <linux-mm@kvack.org>;
        Sat, 10 Jun 2017 08:56:42 -0700 (PDT)
Date: Sat, 10 Jun 2017 17:56:25 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 13/34] x86/mm: Add support for early encrypt/decrypt
 of memory
Message-ID: <20170610155624.q3jh6q2wpnepxpsw@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191527.28645.84593.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191527.28645.84593.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:15:27PM -0500, Tom Lendacky wrote:
> Add support to be able to either encrypt or decrypt data in place during
> the early stages of booting the kernel. This does not change the memory
> encryption attribute - it is used for ensuring that data present in either
> an encrypted or decrypted memory area is in the proper state (for example
> the initrd will have been loaded by the boot loader and will not be
> encrypted, but the memory that it resides in is marked as encrypted).
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |   15 +++++++
>  arch/x86/mm/mem_encrypt.c          |   76 ++++++++++++++++++++++++++++++++++++
>  2 files changed, 91 insertions(+)

Patches 11-13:

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
