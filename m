Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24E166B53CE
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:16:59 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id h85so1504755oib.9
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:16:59 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s12si1220347otp.8.2018.11.29.10.16.58
        for <linux-mm@kvack.org>;
        Thu, 29 Nov 2018 10:16:58 -0800 (PST)
Date: Thu, 29 Nov 2018 18:16:51 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v8 0/8] arm64: untag user pointers passed to the kernel
Message-ID: <20181129181650.GG22027@arrakis.emea.arm.com>
References: <cover.1541687720.git.andreyknvl@google.com>
 <CAAeHK+w1Qv6owkdWfjbXMFqOA8BURDN5gviw8vpgi3eon1dWmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+w1Qv6owkdWfjbXMFqOA8BURDN5gviw8vpgi3eon1dWmA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrey,

On Thu, Nov 08, 2018 at 03:48:10PM +0100, Andrey Konovalov wrote:
> On Thu, Nov 8, 2018 at 3:36 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > Changes in v8:
> > - Rebased onto 65102238 (4.20-rc1).
> > - Added a note to the cover letter on why syscall wrappers/shims that untag
> >   user pointers won't work.
> > - Added a note to the cover letter that this patchset has been merged into
> >   the Pixel 2 kernel tree.
> > - Documentation fixes, in particular added a list of syscalls that don't
> >   support tagged user pointers.
> 
> I've changed the documentation to be more specific, please take a look.
> 
> I haven't done anything about adding a way for the user to find out
> that the kernel supports this ABI extension. I don't know what would
> the the preferred way to do this, and we haven't received any comments
> on that from anybody else. Probing "on some innocuous syscall
> currently returning -EFAULT on tagged pointer arguments" works though,
> as you mentioned.

We've had some internal discussions and also talked to some people at
Plumbers. I think the best option is to introduce an AT_FLAGS bit to
describe the ABI relaxation on tagged pointers. Vincenzo is going to
propose a patch on top of this series.

> As mentioned in the cover letter, this patchset has been merged into
> the Pixel 2 kernel tree.

I just hope it's not enabled on production kernels, it would introduce
a user ABI that may differ from what ends up upstream.

-- 
Catalin
