Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 044C16B7A32
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:34:41 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id j202so12302959itj.1
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:34:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c30sor543459jak.4.2018.12.06.04.34.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 04:34:40 -0800 (PST)
MIME-Version: 1.0
References: <cover.1541687720.git.andreyknvl@google.com> <4a4063a3e074608b99cf22ab447fecc36d056251.1541687720.git.andreyknvl@google.com>
 <20181129182218.GH22027@arrakis.emea.arm.com>
In-Reply-To: <20181129182218.GH22027@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 6 Dec 2018 13:34:28 +0100
Message-ID: <CAAeHK+z3uJrkwunH6DDuJOVg_trk6pmKgN4QLx7LnDLEP1TSDw@mail.gmail.com>
Subject: Re: [PATCH v8 1/8] arm64: add type casts to untagged_addr macro
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgenii Stepanov <eugenis@google.com>

On Thu, Nov 29, 2018 at 7:22 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Thu, Nov 08, 2018 at 03:36:08PM +0100, Andrey Konovalov wrote:
> > This patch makes the untagged_addr macro accept all kinds of address types
> > (void *, unsigned long, etc.) and allows not to specify type casts in each
> > place where it is used. This is done by using __typeof__.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  arch/arm64/include/asm/uaccess.h | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> > index 07c34087bd5e..c1325271e368 100644
> > --- a/arch/arm64/include/asm/uaccess.h
> > +++ b/arch/arm64/include/asm/uaccess.h
> > @@ -101,7 +101,8 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
> >   * up with a tagged userland pointer. Clear the tag to get a sane pointer to
> >   * pass on to access_ok(), for instance.
> >   */
> > -#define untagged_addr(addr)          sign_extend64(addr, 55)
> > +#define untagged_addr(addr)          \
> > +     ((__typeof__(addr))sign_extend64((__u64)(addr), 55))
>
> Nitpick: same comment as here (use u64):
>
> http://lkml.kernel.org/r/20181123173739.osgvnnhmptdgtlnl@lakrids.cambridge.arm.com

Will do in v9.

>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
>
> (not acking the whole series just yet, only specific patches to remember
> what I reviewed)

OK.

Thanks!
