Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E09B6B0292
	for <linux-mm@kvack.org>; Sun, 11 Jun 2017 15:44:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w91so18706636wrb.13
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 12:44:33 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id t31si7967883wrc.248.2017.06.11.12.44.31
        for <linux-mm@kvack.org>;
        Sun, 11 Jun 2017 12:44:31 -0700 (PDT)
Date: Sun, 11 Jun 2017 21:44:11 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 18/34] x86/efi: Update EFI pagetable creation to work
 with SME
Message-ID: <20170611194411.shbwwf34ftumipab@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191627.28645.4398.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191627.28645.4398.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:16:27PM -0500, Tom Lendacky wrote:
> When SME is active, pagetable entries created for EFI need to have the
> encryption mask set as necessary.
> 
> When the new pagetable pages are allocated they are mapped encrypted. So,
> update the efi_pgt value that will be used in cr3 to include the encryption
> mask so that the PGD table can be read successfully. The pagetable mapping
> as well as the kernel are also added to the pagetable mapping as encrypted.
> All other EFI mappings are mapped decrypted (tables, etc.).
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/platform/efi/efi_64.c |   15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)

patches 15-18:

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
