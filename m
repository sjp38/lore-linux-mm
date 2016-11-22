Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC286B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 13:58:22 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so13788555wme.5
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 10:58:22 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id o9si3964762wmo.54.2016.11.22.10.58.20
        for <linux-mm@kvack.org>;
        Tue, 22 Nov 2016 10:58:20 -0800 (PST)
Date: Tue, 22 Nov 2016 19:58:18 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 20/20] x86: Add support to make use of Secure
 Memory Encryption
Message-ID: <20161122185818.k2znytnjjkh2ygpy@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003838.3280.23327.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20161110003838.3280.23327.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Nov 09, 2016 at 06:38:38PM -0600, Tom Lendacky wrote:
> This patch adds the support to check if SME has been enabled and if the
> mem_encrypt=on command line option is set. If both of these conditions
> are true, then the encryption mask is set and the kernel is encrypted
> "in place."

Something went wrong here - 19/20 and 20/20 have the same Subject and
commit message.

Care to resend only 19 and 20 with the above fixed?

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
