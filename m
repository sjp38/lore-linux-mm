Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFBC26B7A36
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:36:58 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id v3so660400itf.4
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:36:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor126933ioj.113.2018.12.06.04.36.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 04:36:57 -0800 (PST)
MIME-Version: 1.0
References: <cover.1541687720.git.andreyknvl@google.com> <c9028422854fb5bfb79d798397b30d4701207062.1541687720.git.andreyknvl@google.com>
 <20181129182323.GI22027@arrakis.emea.arm.com>
In-Reply-To: <20181129182323.GI22027@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 6 Dec 2018 13:36:46 +0100
Message-ID: <CAAeHK+y7AwdXsEgBYqLUzps2K8aGcbDsSpS+obCs11voZX55og@mail.gmail.com>
Subject: Re: [PATCH v8 2/8] uaccess: add untagged_addr definition for other arches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgenii Stepanov <eugenis@google.com>

On Thu, Nov 29, 2018 at 7:23 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Thu, Nov 08, 2018 at 03:36:09PM +0100, Andrey Konovalov wrote:
> > diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> > index efe79c1cdd47..c045b4eff95e 100644
> > --- a/include/linux/uaccess.h
> > +++ b/include/linux/uaccess.h
> > @@ -13,6 +13,10 @@
> >
> >  #include <asm/uaccess.h>
> >
> > +#ifndef untagged_addr
> > +#define untagged_addr(addr) addr
> > +#endif
>
> Nitpick: add braces around (addr). Otherwise:

Will do in v9, thanks!

>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
