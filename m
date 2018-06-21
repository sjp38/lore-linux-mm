Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7CF46B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 09:39:15 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v71-v6so1767373oie.20
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 06:39:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1-v6sor1905529otj.252.2018.06.21.06.39.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 06:39:14 -0700 (PDT)
MIME-Version: 1.0
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
 <CAGXu5jLt8Zv-p=9J590WFppc3O6LWrAVdi-xtU7r_8f4j0XeRg@mail.gmail.com> <CAG48ez2uuQkSS9DLz6j5HbpuxaHMyAVYGMM+xoZEo51N=sHmdg@mail.gmail.com>
In-Reply-To: <CAG48ez2uuQkSS9DLz6j5HbpuxaHMyAVYGMM+xoZEo51N=sHmdg@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 21 Jun 2018 15:39:03 +0200
Message-ID: <CAG48ez1eAKVy13tmAxrVkRqj2Fd+wduqBt4fzMBjY5FA1aFFmw@mail.gmail.com>
Subject: Re: [PATCH 0/3] KASLR feature to randomize each loadable module
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, rick.p.edgecombe@intel.com
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, kristen.c.accardi@intel.com, Dave Hansen <dave.hansen@intel.com>, arjan.van.de.ven@intel.com

On Thu, Jun 21, 2018 at 3:37 PM Jann Horn <jannh@google.com> wrote:
>
> On Thu, Jun 21, 2018 at 12:34 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Wed, Jun 20, 2018 at 3:09 PM, Rick Edgecombe
> > <rick.p.edgecombe@intel.com> wrote:
> > > This patch changes the module loading KASLR algorithm to randomize the position
> > > of each module text section allocation with at least 18 bits of entropy in the
> > > typical case. It used on x86_64 only for now.
> >
> > Very cool! Thanks for sending the series. :)
> >
> > > Today the RANDOMIZE_BASE feature randomizes the base address where the module
> > > allocations begin with 10 bits of entropy. From here, a highly deterministic
> > > algorithm allocates space for the modules as they are loaded and un-loaded. If
> > > an attacker can predict the order and identities for modules that will be
> > > loaded, then a single text address leak can give the attacker access to the
> >
> > nit: "text address" -> "module text address"
> >
> > > So the defensive strength of this algorithm in typical usage (<800 modules) for
> > > x86_64 should be at least 18 bits, even if an address from the random area
> > > leaks.
> >
> > And most systems have <200 modules, really. I have 113 on a desktop
> > right now, 63 on a server. So this looks like a trivial win.
[...]
> Also: What's the impact on memory usage? Is this going to increase the
> number of pagetables that need to be allocated by the kernel per
> module_alloc() by 4K or 8K or so?

Sorry, I meant increase the amount of memory used by pagetables by 4K
or 8K, not the number of pagetables.
