Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AACB16B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:41:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so37733316wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:41:22 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id wp4si4192094wjb.173.2016.04.27.05.41.21
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 05:41:21 -0700 (PDT)
Date: Tue, 22 Mar 2016 14:00:58 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
Message-ID: <20160322130058.GA16528@xo-6d-61-c0.localdomain>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Hi!

> This RFC patch series provides support for AMD's new Secure Memory
> Encryption (SME) feature.
> 
> SME can be used to mark individual pages of memory as encrypted through the
> page tables. A page of memory that is marked encrypted will be automatically
> decrypted when read from DRAM and will be automatically encrypted when
> written to DRAM. Details on SME can found in the links below.

Well, actually brief summary should go to changelog and probably to the documentation,
too...

Why would I want SME on my system? My system seems to work without it.

Does it protect against cold boot attacks? Rowhammer (I guess not?)

Does it cost some performance?

Does it break debugging over JTAG?

> The approach that this patch series takes is to encrypt everything possible
> starting early in the boot where the kernel is encrypted. Using the page
> table macros the encryption mask can be incorporated into all page table
> entries and page allocations. By updating the protection map, userspace
> allocations are also marked encrypted. Certain data must be accounted for
> as having been placed in memory before SME was enabled (EFI, initrd, etc.)
> and accessed accordingly.

Do you also need to do something special for device DMA?

Thanks,

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
