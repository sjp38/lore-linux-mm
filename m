Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 871A56B0390
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:05:29 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p78so92664775lfd.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:05:29 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id y13si11677368lfd.355.2017.03.21.11.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 11:05:28 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id g70so13831917lfh.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:05:27 -0700 (PDT)
Date: Tue, 21 Mar 2017 21:05:25 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [Q] Figuring out task mode
Message-ID: <20170321180525.GC21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan>
 <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

/I renamed the mail's subject/

On Tue, Mar 21, 2017 at 10:45:57AM -0700, Andy Lutomirski wrote:
> >> +             task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
> >>               current->thread.status &= ~TS_COMPAT;
> >
> > Hi! I must admit I didn't follow close the overall series (so can't
> > comment much here :) but I have a slightly unrelated question -- is
> > there a way to figure out if task is running in x32 mode say with
> > some ptrace or procfs sign?
> 
> You should be able to figure out of a *syscall* is x32 by simply
> looking at bit 30 in the syscall number.  (This is unlike i386, which
> is currently not reflected in ptrace.)

Yes, syscall number will help but from criu perpspective (until
Dima's patches are merged into mainlie) we need to figure out
if we can dump x32 tasks without running parasite code inside,
ie via plain ptrace call or some procfs output. But looks like
it's impossible for now.

> Do we actually have an x32 per-task mode at all?  If so, maybe we can
> just remove it on top of Dmitry's series.

Don't think so, x32 should be set upon exec and without Dima's series
it is immutable I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
