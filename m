Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C30036B7A40
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:44:36 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id b21so246840ioj.8
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:44:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16sor119186ion.108.2018.12.06.04.44.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 04:44:35 -0800 (PST)
MIME-Version: 1.0
References: <cover.1541687720.git.andreyknvl@google.com> <CAAeHK+w1Qv6owkdWfjbXMFqOA8BURDN5gviw8vpgi3eon1dWmA@mail.gmail.com>
 <20181129181650.GG22027@arrakis.emea.arm.com>
In-Reply-To: <20181129181650.GG22027@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 6 Dec 2018 13:44:24 +0100
Message-ID: <CAAeHK+x9CuqqgvP6pZEV1Gz5cFHNpwsuUDbWQFHFzTy8GBMPKA@mail.gmail.com>
Subject: Re: [PATCH v8 0/8] arm64: untag user pointers passed to the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Nov 29, 2018 at 7:16 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> Hi Andrey,
>
> On Thu, Nov 08, 2018 at 03:48:10PM +0100, Andrey Konovalov wrote:
> > On Thu, Nov 8, 2018 at 3:36 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > > Changes in v8:
> > > - Rebased onto 65102238 (4.20-rc1).
> > > - Added a note to the cover letter on why syscall wrappers/shims that untag
> > >   user pointers won't work.
> > > - Added a note to the cover letter that this patchset has been merged into
> > >   the Pixel 2 kernel tree.
> > > - Documentation fixes, in particular added a list of syscalls that don't
> > >   support tagged user pointers.
> >
> > I've changed the documentation to be more specific, please take a look.
> >
> > I haven't done anything about adding a way for the user to find out
> > that the kernel supports this ABI extension. I don't know what would
> > the the preferred way to do this, and we haven't received any comments
> > on that from anybody else. Probing "on some innocuous syscall
> > currently returning -EFAULT on tagged pointer arguments" works though,
> > as you mentioned.
>
> We've had some internal discussions and also talked to some people at
> Plumbers. I think the best option is to introduce an AT_FLAGS bit to
> describe the ABI relaxation on tagged pointers. Vincenzo is going to
> propose a patch on top of this series.

So should I wait for a patch from Vincenzo before posting v9 or post
it as is? Or try to develop this patch myself?

>
> > As mentioned in the cover letter, this patchset has been merged into
> > the Pixel 2 kernel tree.
>
> I just hope it's not enabled on production kernels, it would introduce
> a user ABI that may differ from what ends up upstream.
>
> --
> Catalin
