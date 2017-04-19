Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB34F6B03A6
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 11:38:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d79so1494617wmi.8
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:38:36 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id r15si4130867wrr.287.2017.04.19.08.38.34
        for <linux-mm@kvack.org>;
        Wed, 19 Apr 2017 08:38:35 -0700 (PDT)
Date: Wed, 19 Apr 2017 17:38:19 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 01/32] x86: Documentation for AMD Secure Memory
 Encryption (SME)
Message-ID: <20170419153818.3pl3gkdpe42lve44@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211625.10190.52568.stgit@tlendack-t1.amdoffice.net>
 <20170419090224.frmv2jhwfwoxvdie@pd.tnic>
 <bbda868c-9b34-4404-f563-98b000124ac5@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bbda868c-9b34-4404-f563-98b000124ac5@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Apr 19, 2017 at 09:23:47AM -0500, Tom Lendacky wrote:
> Btw, I tried to update all the subjects and descriptions to be
> more descriptive but I'm sure there is still room for improvement
> so keep the comments on them coming.

No worries there :)

> Note, just because the bit is set in %cr3 doesn't mean the full
> hierarchy is encrypted. Each level in the hierarchy needs to have the
> encryption bit set. So, theoretically, you could have the encryption
> bit set in %cr3 so that the PGD is encrypted, but not set the encryption
> bit in the PGD entry for a PUD and so the PUD pointed to by that entry
> would not be encrypted.

Ha, that is a nice detail I didn't realize. You could add it to the text.

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
