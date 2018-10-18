Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 003106B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 13:31:44 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 91so22202997otr.18
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 10:31:44 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m76-v6si10122759oig.216.2018.10.18.10.31.43
        for <linux-mm@kvack.org>;
        Thu, 18 Oct 2018 10:31:43 -0700 (PDT)
Date: Thu, 18 Oct 2018 18:31:36 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 7/8] arm64: update
 Documentation/arm64/tagged-pointers.txt
Message-ID: <20181018173135.GF237391@arrakis.emea.arm.com>
References: <cover.1538485901.git.andreyknvl@google.com>
 <47a464307d4df3c0cb65f88d1fe83f9a741dd74b.1538485901.git.andreyknvl@google.com>
 <20181003173256.GG12998@arrakis.emea.arm.com>
 <CAAeHK+yPCRNAOSi6OpYC_Tdbo9SoXRVRbx8pjXNq96v8csO-Wg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+yPCRNAOSi6OpYC_Tdbo9SoXRVRbx8pjXNq96v8csO-Wg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Oct 10, 2018 at 04:09:25PM +0200, Andrey Konovalov wrote:
> On Wed, Oct 3, 2018 at 7:32 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Tue, Oct 02, 2018 at 03:12:42PM +0200, Andrey Konovalov wrote:
[...]
> > Also, how is user space supposed to know that it can now pass tagged
> > pointers into the kernel? An ABI change (or relaxation), needs to be
> > advertised by the kernel, usually via a new HWCAP bit (e.g. HWCAP_TBI).
> > Once we have a HWCAP bit in place, we need to be pretty clear about
> > which syscalls can and cannot cope with tagged pointers. The "as of now"
> > implies potential further relaxation which, again, would need to be
> > advertised to user in some (additional) way.
> 
> How exactly should I do that? Something like this [1]? Or is it only
> for hardware specific things and for this patchset I need to do
> something else?
> 
> [1] https://github.com/torvalds/linux/commit/7206dc93a58fb76421c4411eefa3c003337bcb2d

Thinking some more on this, we should probably keep the HWCAP_* bits for
actual hardware features. Maybe someone else has a better idea (the
linux-abi list?). An option would be to make use of AT_FLAGS auxv
(currently 0) in Linux. I've seen some MIPS patches in the past but
nothing upstream.

Yet another option would be for the user to probe on some innocuous
syscall currently returning -EFAULT on tagged pointer arguments but I
don't particularly like this.

> >> - - pointer arguments to system calls, including pointers in structures
> >> -   passed to system calls,
> >> +  - pointer arguments (including pointers in structures), which don't
> >> +    describe virtual memory ranges, passed to system calls
> >
> > I think we need to be more precise here...
> 
> In what way?

In the way of being explicit about which syscalls support tagged
pointers, unless we find a good reason to support tagged pointers on all
syscalls and avoid any lists.

-- 
Catalin
