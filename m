Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE11682F66
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:19:03 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l15so64226999lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:19:03 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id v62si10989947wmg.23.2016.04.15.02.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:19:02 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n3so4431669wmn.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:19:02 -0700 (PDT)
Date: Fri, 15 Apr 2016 11:18:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv2] x86/vdso: add mremap hook to vm_special_mapping
Message-ID: <20160415091859.GA10167@gmail.com>
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460651571-10545-1-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrUhDvdyJV53Am2sgefyMJmHs5u1voOM2N76Si7BTtJWaQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUhDvdyJV53Am2sgefyMJmHs5u1voOM2N76Si7BTtJWaQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> > +       if (regs->ip == (unsigned long)current->mm->context.vdso +
> > +                       vdso_image_32.sym_int80_landing_pad
> > +#ifdef CONFIG_IA32_EMULATION
> > +               && current_thread_info()->status & TS_COMPAT
> > +#endif
> 
> Instead of ifdef, use the (grossly misnamed) is_ia32_task() helper for
> this, please.

Please also let's do the rename.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
