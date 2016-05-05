Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75E2D6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 07:52:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j8so11842538lfd.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 04:52:45 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id n10si10992815wjy.217.2016.05.05.04.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 04:52:43 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id w143so2993509wmw.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 04:52:43 -0700 (PDT)
Date: Thu, 5 May 2016 13:52:40 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv8 1/2] x86/vdso: add mremap hook to vm_special_mapping
Message-ID: <20160505115240.GA29616@gmail.com>
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1461584223-9418-1-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrVJhooHkMMVY_702p88-jYRJibXi38WB+fAizAt6S3PjQ@mail.gmail.com>
 <e0a10957-ddf7-1bc4-fad6-8b5836628fce@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e0a10957-ddf7-1bc4-fad6-8b5836628fce@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>


* Dmitry Safonov <dsafonov@virtuozzo.com> wrote:

> On 04/26/2016 12:38 AM, Andy Lutomirski wrote:
> >On Mon, Apr 25, 2016 at 4:37 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> >>Add possibility for userspace 32-bit applications to move
> >>vdso mapping. Previously, when userspace app called
> >>mremap for vdso, in return path it would land on previous
> >>address of vdso page, resulting in segmentation violation.
> >>Now it lands fine and returns to userspace with remapped vdso.
> >>This will also fix context.vdso pointer for 64-bit, which does not
> >>affect the user of vdso after mremap by now, but this may change.
> >>
> >>As suggested by Andy, return EINVAL for mremap that splits vdso image.
> >>
> >>Renamed and moved text_mapping structure declaration inside
> >>map_vdso, as it used only there and now it complement
> >>vvar_mapping variable.
> >>
> >>There is still problem for remapping vdso in glibc applications:
> >>linker relocates addresses for syscalls on vdso page, so
> >>you need to relink with the new addresses. Or the next syscall
> >>through glibc may fail:
> >>   Program received signal SIGSEGV, Segmentation fault.
> >>   #0  0xf7fd9b80 in __kernel_vsyscall ()
> >>   #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
> >Acked-by: Andy Lutomirski <luto@kernel.org>
> >
> >Ingo, can you apply this?
> 
> Hm, so I'm not sure - should I resend those two?
> Or just ping?

Please send a clean series with updated Acked-by's, etc.

Thanks!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
