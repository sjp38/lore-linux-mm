Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 091216B0292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 06:58:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so3526892wrc.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 03:58:32 -0700 (PDT)
Received: from mail-wr0-x235.google.com (mail-wr0-x235.google.com. [2a00:1450:400c:c0c::235])
        by mx.google.com with ESMTPS id c66si882314wmf.94.2017.06.22.03.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 03:58:31 -0700 (PDT)
Received: by mail-wr0-x235.google.com with SMTP id 77so18233014wrb.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 03:58:31 -0700 (PDT)
Date: Thu, 22 Jun 2017 11:58:30 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v7 18/36] x86/efi: Update EFI pagetable creation to work
 with SME
Message-ID: <20170622105830.GB3129@codeblueprint.co.uk>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185317.18967.99499.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616185317.18967.99499.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, 16 Jun, at 01:53:17PM, Tom Lendacky wrote:
> When SME is active, pagetable entries created for EFI need to have the
> encryption mask set as necessary.
> 
> When the new pagetable pages are allocated they are mapped encrypted. So,
> update the efi_pgt value that will be used in cr3 to include the encryption
> mask so that the PGD table can be read successfully. The pagetable mapping
> as well as the kernel are also added to the pagetable mapping as encrypted.
> All other EFI mappings are mapped decrypted (tables, etc.).
> 
> Reviewed-by: Borislav Petkov <bp@suse.de>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/platform/efi/efi_64.c |   15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
 
Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
