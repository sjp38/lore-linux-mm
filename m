Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07BEF831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 13:01:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p134so2236941wmg.3
        for <linux-mm@kvack.org>; Thu, 04 May 2017 10:01:18 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id 31si3239528wrz.258.2017.05.04.10.01.17
        for <linux-mm@kvack.org>;
        Thu, 04 May 2017 10:01:17 -0700 (PDT)
Date: Thu, 4 May 2017 19:01:06 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 09/32] x86/mm: Provide general kernel support for
 memory encryption
Message-ID: <20170504170106.mocn2y6onm7eax3g@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211754.10190.25082.stgit@tlendack-t1.amdoffice.net>
 <20170427161227.c57dkvghz63pvmu2@pd.tnic>
 <0b6e4055-8e07-3a71-3d52-12b0395c8f04@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <0b6e4055-8e07-3a71-3d52-12b0395c8f04@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Thu, May 04, 2017 at 09:34:09AM -0500, Tom Lendacky wrote:
> I masked it out here based on a previous comment from Dave Hansen:
> 
>   http://marc.info/?l=linux-kernel&m=148778719826905&w=2
> 
> I could move the __sme_clr into the individual defines of:

Nah, it is fine as it is. I was just wondering...

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
