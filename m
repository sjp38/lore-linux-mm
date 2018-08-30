Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7435A6B5151
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:48:17 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m207-v6so1610415itg.5
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 04:48:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2-v6sor2272459jac.44.2018.08.30.04.48.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 04:48:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cover.1535629099.git.andreyknvl@google.com>
References: <cover.1535629099.git.andreyknvl@google.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 30 Aug 2018 13:48:15 +0200
Message-ID: <CAAeHK+yyX95aBzzXRoSUYj1QF8c-7uwGNeuwfBU8zOjOWyO_Wg@mail.gmail.com>
Subject: Re: [PATCH v6 00/11] arm64: untag user pointers passed to the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 30, 2018 at 1:41 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> arm64 has a feature called Top Byte Ignore, which allows to embed pointer
> tags into the top byte of each pointer. Userspace programs (such as
> HWASan, a memory debugging tool [1]) might use this feature and pass
> tagged user pointers to the kernel through syscalls or other interfaces.
>
> This patch makes a few of the kernel interfaces accept tagged user
> pointers. The kernel is already able to handle user faults with tagged
> pointers and has the untagged_addr macro, which this patchset reuses.
>
> Thanks!
>
> [1] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html
>
> Changes in v6:
> - Added annotations for user pointer casts found by sparse.

Hi Catalin,

I've added annotations for the user pointer casts pointed by the new
sparse flag -Wcast-from-as as you asked. I've used __force casts
instead of adding specialized macros.

There are also non annotated casts for other pointer types (iomem,
rcu) which are detected with the new flag, should I annotate those as
well?

I'm not sure though what value would that bring though, as there are
~3000 various sparse warnings produced with the default flags anyway.

WDYT?

Thanks!

[1] https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292
