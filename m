Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA4B6B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 10:41:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so11153905wmu.1
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 07:41:41 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id xw2si11802069wjc.22.2016.11.22.07.41.39
        for <linux-mm@kvack.org>;
        Tue, 22 Nov 2016 07:41:39 -0800 (PST)
Date: Tue, 22 Nov 2016 16:41:37 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 13/20] x86: DMA support for memory encryption
Message-ID: <20161122154137.z5vp3xcl5cpesuiz@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003723.3280.62636.stgit@tlendack-t1.amdoffice.net>
 <20161115171443-mutt-send-email-mst@kernel.org>
 <4d97f998-5835-f4e0-9840-7f7979251275@amd.com>
 <20161122113859.5dtlrfgizwpum6st@pd.tnic>
 <20161122171455-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20161122171455-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Nov 22, 2016 at 05:22:38PM +0200, Michael S. Tsirkin wrote:
> The issue is it's a (potential) security hole, not a slowdown.

How? Because the bounce buffers will be unencrypted and someone might
intercept them?

> To disable unsecure things. If someone enables SEV one might have an
> expectation of security.  Might help push vendors to do the right thing
> as a side effect.

Ok, you're looking at the SEV-cloud-multiple-guests aspect. Right, that
makes sense.

I guess for SEV we should even flip the logic: disable such devices by
default and an opt-in option to enable them and issue a big fat warning.
I'd even want to let the guest users know that they're on a system which
cannot give them encrypted DMA to some devices...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
