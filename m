Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD81A6B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 06:25:44 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id x85so2797926oix.8
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 03:25:44 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g8si6060038otc.319.2018.03.08.03.25.43
        for <linux-mm@kvack.org>;
        Thu, 08 Mar 2018 03:25:43 -0800 (PST)
Date: Thu, 8 Mar 2018 11:25:32 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Message-ID: <20180308112532.4ijhy4dyb6u72nvl@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
 <20180305144405.jhrftj56hnlfl4ko@lakrids.cambridge.arm.com>
 <CAAeHK+x0gjQT95Suq-xqpbSUVo4Z3r8j48vOOG+NCgGS+cnAGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+x0gjQT95Suq-xqpbSUVo4Z3r8j48vOOG+NCgGS+cnAGA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Tue, Mar 06, 2018 at 07:38:08PM +0100, Andrey Konovalov wrote:
> On Mon, Mar 5, 2018 at 3:44 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Fri, Mar 02, 2018 at 08:44:28PM +0100, Andrey Konovalov wrote:
> >> +
> >> +     for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
> >> +             if (*shadow != tag) {
> >> +                     /* Report invalid-access bug here */
> >> +                     return;
> >
> > Huh? Should that be a TODO?
> 
> This is fixed in one of the next commits. I decided to split the main
> runtime logic and the reporting parts, so this comment is a
> placeholder, which is replaced with the proper error reporting
> function call later in the patch series. I can make it a /* TODO:
> comment */, if you think that looks better.

It might be preferable to introdcue the report functions first (i.e.
swap this patch with the next one).

Those will be unused, but since they're not static, you shouldn't get
any build warnings. Then the hooks can call the report functions as soon
as they're introduced.

Thanks,
Mark.
