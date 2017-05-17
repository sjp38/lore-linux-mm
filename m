Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8696B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 03:06:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g12so464324wrg.15
        for <linux-mm@kvack.org>; Wed, 17 May 2017 00:06:08 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id c65si16238790wmf.87.2017.05.17.00.06.07
        for <linux-mm@kvack.org>;
        Wed, 17 May 2017 00:06:07 -0700 (PDT)
Date: Wed, 17 May 2017 09:05:56 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 06/32] x86/mm: Add Secure Memory Encryption (SME)
 support
Message-ID: <20170517070556.2lwwnfbre34xqr7s@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211727.10190.18774.stgit@tlendack-t1.amdoffice.net>
 <20170427154631.2tsqgax4kqcvydnx@pd.tnic>
 <d9d9f10a-0ce5-53e8-41f5-f8690dbd7362@amd.com>
 <20170504143622.zy2f66e4mkm6xvsq@pd.tnic>
 <6d266f5b-c28d-fe19-24b5-5133532f9eea@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <6d266f5b-c28d-fe19-24b5-5133532f9eea@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, May 16, 2017 at 02:28:42PM -0500, Tom Lendacky wrote:
> It's most problematic when CONFIG_AMD_MEM_ENCRYPT is not defined since
> we never include an asm/ version from the linux/ path.  I could create
> a mem_encrypt.h in include/asm-generic/ that contains the info that
> is in the !CONFIG_AMD_MEM_ENCRYPT path of the linux/ version. Let me
> look into that.

So we need to keep asm/ and linux/ apart. The linux/ stuff is generic,
global, more or less. The asm/ is arch-specific. So they shouldn't be
overlapping wrt definitions, IMHO.

So asm-generic is the proper approach here because then you won't need
the ifndef fun.

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
