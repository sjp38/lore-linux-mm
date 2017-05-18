Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C44B831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:02:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d127so10115129wmf.15
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:02:02 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id q4si6630326wrb.303.2017.05.18.10.02.00
        for <linux-mm@kvack.org>;
        Thu, 18 May 2017 10:02:01 -0700 (PDT)
Date: Thu, 18 May 2017 19:01:53 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 31/32] x86: Add sysfs support for Secure Memory
 Encryption
Message-ID: <20170518170153.eqiyat5s6q3yeejl@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212212.10190.73484.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418212212.10190.73484.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:22:12PM -0500, Tom Lendacky wrote:
> Add sysfs support for SME so that user-space utilities (kdump, etc.) can
> determine if SME is active.

But why do user-space tools need to know that?

I mean, when we load the kdump kernel, we do it with the first kernel,
with the kexec_load() syscall, AFAICT. And that code does a lot of
things during that init, like machine_kexec_prepare()->init_pgtable() to
prepare the ident mapping of the second kernel, for example.

What I'm aiming at is that the first kernel knows *exactly* whether SME
is enabled or not and doesn't need to tell the second one through some
sysfs entries - it can do that during loading.

So I don't think we need any userspace things at all...

Or?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
