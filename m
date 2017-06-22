Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32FC46B0292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:04:09 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v60so3555330wrc.7
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 04:04:09 -0700 (PDT)
Received: from mail-wr0-x234.google.com (mail-wr0-x234.google.com. [2a00:1450:400c:c0c::234])
        by mx.google.com with ESMTPS id k70si955041wmd.148.2017.06.22.04.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 04:04:07 -0700 (PDT)
Received: by mail-wr0-x234.google.com with SMTP id k67so18312718wrc.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 04:04:07 -0700 (PDT)
Date: Thu, 22 Jun 2017 12:04:05 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v7 19/36] x86/mm: Add support to access boot related data
 in the clear
Message-ID: <20170622110405.GC3129@codeblueprint.co.uk>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185326.18967.43278.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616185326.18967.43278.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, 16 Jun, at 01:53:26PM, Tom Lendacky wrote:
> Boot data (such as EFI related data) is not encrypted when the system is
> booted because UEFI/BIOS does not run with SME active. In order to access
> this data properly it needs to be mapped decrypted.
> 
> Update early_memremap() to provide an arch specific routine to modify the
> pagetable protection attributes before they are applied to the new
> mapping. This is used to remove the encryption mask for boot related data.
> 
> Update memremap() to provide an arch specific routine to determine if RAM
> remapping is allowed.  RAM remapping will cause an encrypted mapping to be
> generated. By preventing RAM remapping, ioremap_cache() will be used
> instead, which will provide a decrypted mapping of the boot related data.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/io.h |    5 +
>  arch/x86/mm/ioremap.c     |  179 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/io.h        |    2 +
>  kernel/memremap.c         |   20 ++++-
>  mm/early_ioremap.c        |   18 ++++-
>  5 files changed, 217 insertions(+), 7 deletions(-)

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
