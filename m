Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F49F83292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:25:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g46so1562199wrd.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:25:52 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id i194si394127wmf.128.2017.06.14.09.25.51
        for <linux-mm@kvack.org>;
        Wed, 14 Jun 2017 09:25:51 -0700 (PDT)
Date: Wed, 14 Jun 2017 18:25:48 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 22/34] x86/mm: Add support for changing the memory
 encryption attribute
Message-ID: <20170614162548.crwm44epddyrtgm6@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191659.28645.1669.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191659.28645.1669.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:17:00PM -0500, Tom Lendacky wrote:
> Add support for changing the memory encryption attribute for one or more
> memory pages. This will be useful when we have to change the AP trampoline
> area to not be encrypted. Or when we need to change the SWIOTLB area to
> not be encrypted in support of devices that can't support the encryption
> mask range.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/set_memory.h |    3 ++
>  arch/x86/mm/pageattr.c            |   62 +++++++++++++++++++++++++++++++++++++
>  2 files changed, 65 insertions(+)

Patches 21-22:

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
