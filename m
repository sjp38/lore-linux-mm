Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A372D6B4315
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 13:29:55 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id u20so9755365pfa.1
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:29:55 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t12si994686plq.190.2018.11.26.10.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 10:29:54 -0800 (PST)
Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B80C92148E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:29:53 +0000 (UTC)
Received: by mail-wm1-f44.google.com with SMTP id k198so19662494wmd.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:29:53 -0800 (PST)
MIME-Version: 1.0
References: <20181119214809.6086-1-yu-cheng.yu@intel.com> <CALCETrWLtpfkecfUAXJ64Z5xDeHPJxTQSci+T4RCem7vCqorTw@mail.gmail.com>
 <35b33f293bc392df71710102f38fa6a40d0bb996.camel@intel.com>
In-Reply-To: <35b33f293bc392df71710102f38fa6a40d0bb996.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 26 Nov 2018 10:29:40 -0800
Message-ID: <CALCETrV4BP6gTgVZos19WZrbgEH7t4PqPOeP2VJte1kE=ehokg@mail.gmail.com>
Subject: Re: [RFC PATCH v6 00/26] Control-flow Enforcement: Shadow Stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Andrew Lutomirski <luto@kernel.org>, Florian Weimer <fweimer@redhat.com>, Carlos O'Donell <carlos@redhat.com>, Rich Felker <dalias@libc.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Mon, Nov 26, 2018 at 9:44 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> On Thu, 2018-11-22 at 08:53 -0800, Andy Lutomirski wrote:
> > [cc some more libc folks]

>
> >
> > 2. I want to be able to modify the signal context from a signal
> > handler such that, when the signal handler returns, it will return to
> > a frame higher up on the call stack than where the signal started and
> > to a different RIP value.  How can I do this?  I guess I can modify
> > the shadow stack with WRSS if WR_SHSTK_EN=1, but how do I tell the
> > kernel to kindly skip the frames I want to skip when I do sigreturn()?
> >
> > The reason I'm asking #2 is that I think it's time to resurrect my old
> > vDSO syscall cancellation helper series here:
> >
> > https://lwn.net/Articles/679434/
>
> If tools/testing/selftests/x86/unwind_vdso.c passes, can we say the kernel does
> the right thing?  Or do you have other tests that I can run?

I haven't written the relevant test yet.  Hopefully soon :)
