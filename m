Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD646B03B4
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:39:36 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v60so28375359wrc.7
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:39:36 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id q22si16542752wrb.377.2017.06.21.01.39.34
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 01:39:35 -0700 (PDT)
Date: Wed, 21 Jun 2017 10:39:18 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 20/36] x86, mpparse: Use memremap to map the mpf and
 mpc data
Message-ID: <20170621083918.oa2w5jsxs3si4oln@pd.tnic>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185338.18967.80659.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170616185338.18967.80659.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 01:53:38PM -0500, Tom Lendacky wrote:
> The SMP MP-table is built by UEFI and placed in memory in a decrypted
> state. These tables are accessed using a mix of early_memremap(),
> early_memunmap(), phys_to_virt() and virt_to_phys(). Change all accesses
> to use early_memremap()/early_memunmap(). This allows for proper setting
> of the encryption mask so that the data can be successfully accessed when
> SME is active.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/mpparse.c |   98 ++++++++++++++++++++++++++++++++-------------
>  1 file changed, 70 insertions(+), 28 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

Please put the conversion to pr_fmt() on the TODO list for later.

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
