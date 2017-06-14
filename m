Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 04C626B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:39:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x23so1179357wrb.6
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:39:12 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id y42si473126wrd.240.2017.06.14.09.39.11
        for <linux-mm@kvack.org>;
        Wed, 14 Jun 2017 09:39:11 -0700 (PDT)
Date: Wed, 14 Jun 2017 18:39:04 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 23/34] x86, realmode: Decrypt trampoline area if
 memory encryption is active
Message-ID: <20170614163903.fvlvscewnuk2u75x@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 14, 2017 at 06:24:16PM +0200, Borislav Petkov wrote:
> On Wed, Jun 07, 2017 at 02:17:09PM -0500, Tom Lendacky wrote:
> > When Secure Memory Encryption is enabled, the trampoline area must not
> > be encrypted. A CPU running in real mode will not be able to decrypt
> > memory that has been encrypted because it will not be able to use addresses
> > with the memory encryption mask.
> > 
> > A recent change that added a new system_state value exposed a warning
> > issued by early_ioreamp() when the system_state was not SYSTEM_BOOTING.
> > At the stage where the trampoline area is decrypted, the system_state is
> > now SYSTEM_SCHEDULING. The check was changed to issue a warning if the
> > system_state is greater than or equal to SYSTEM_RUNNING.
> 
> This piece along with the hunk touching system_state absolutely needs to
> be a separate patch as it is unrelated.

Btw, pls send this now and separate from the patchset as it is a bugfix
that should go into sched/core.

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
