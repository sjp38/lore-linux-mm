Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 355636B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 04:26:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n67so2156231wmi.7
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 01:26:00 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id p40si12776912wrc.390.2017.06.20.01.25.58
        for <linux-mm@kvack.org>;
        Tue, 20 Jun 2017 01:25:58 -0700 (PDT)
Date: Tue, 20 Jun 2017 10:25:44 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 11/36] x86/mm: Add SME support for read_cr3_pa()
Message-ID: <20170620082544.uci6unwh4xum5k7n@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185154.18967.71073.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185154.18967.71073.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:51:55PM -0500, Tom Lendacky wrote:
> The cr3 register entry can contain the SME encryption mask that indicates
> the PGD is encrypted.  The encryption mask should not be used when
> creating a virtual address from the cr3 register, so remove the SME
> encryption mask in the read_cr3_pa() function.
> 
> During early boot SME will need to use a native version of read_cr3_pa(),
> so create native_read_cr3_pa().
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/processor-flags.h |    3 ++-
>  arch/x86/include/asm/processor.h       |    5 +++++
>  2 files changed, 7 insertions(+), 1 deletion(-)

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
