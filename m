Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 719AE6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 15:19:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t69so3865312wmt.7
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 12:19:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z66sor293689wmb.12.2017.10.12.12.19.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 12:19:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171012114843.d74096014cb88eedbaa7ac70@linux-foundation.org>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble>
 <20171011170120.7flnk6r77dords7a@treble> <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
 <CAADWXX-M2uftDuCyAS+UMKACC6d-B+Zb-DDNGO76yRS5wuigHw@mail.gmail.com> <20171012114843.d74096014cb88eedbaa7ac70@linux-foundation.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 12 Oct 2017 21:19:01 +0200
Message-ID: <CAMuHMdWmp5cJf82d_V8=Kzii9r6oFpDMGitBsLRUMNW2HmZxog@mail.gmail.com>
Subject: Re: [lkp-robot] [x86/kconfig] 81d3871900: BUG:unable_to_handle_kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christopher Lameter <cl@linux.com>, Josh Poimboeuf <jpoimboe@redhat.com>, kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, Linux MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matt Mackall <mpm@selenic.com>

On Thu, Oct 12, 2017 at 8:48 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 12 Oct 2017 10:54:57 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>> On Thu, Oct 12, 2017 at 10:05 AM, Christopher Lameter <cl@linux.com> wrote:
>> > On Wed, 11 Oct 2017, Josh Poimboeuf wrote:
>> >
>> >> I failed to add the slab maintainers to CC on the last attempt.  Trying
>> >> again.
>> >
>> > Hmmm... Yea. SLOB is rarely used and tested. Good illustration of a simple
>> > allocator and the K&R mechanism that was used in the early kernels.
>>
>> Should we finally just get rid of SLOB?
>>
>> I'm not happy about the whole "three different allocators" crap. It's
>> been there for much too long, and I've tried to cut it down before.
>> People always protest, but three different allocators, one of which
>> gets basically no testing, is not good.
>
> I am not aware of anyone using slob.  We could disable it in Kconfig
> for a year, see what the feedback looks like.

$ git grep CONFIG_SLOB=y
arch/arm/configs/clps711x_defconfig:CONFIG_SLOB=y
arch/arm/configs/collie_defconfig:CONFIG_SLOB=y
arch/arm/configs/multi_v4t_defconfig:CONFIG_SLOB=y
arch/arm/configs/omap1_defconfig:CONFIG_SLOB=y
arch/arm/configs/pxa_defconfig:CONFIG_SLOB=y
arch/arm/configs/tct_hammer_defconfig:CONFIG_SLOB=y
arch/arm/configs/xcep_defconfig:CONFIG_SLOB=y
arch/blackfin/configs/DNP5370_defconfig:CONFIG_SLOB=y
arch/h8300/configs/edosk2674_defconfig:CONFIG_SLOB=y
arch/h8300/configs/h8300h-sim_defconfig:CONFIG_SLOB=y
arch/h8300/configs/h8s-sim_defconfig:CONFIG_SLOB=y
arch/openrisc/configs/or1ksim_defconfig:CONFIG_SLOB=y
arch/sh/configs/rsk7201_defconfig:CONFIG_SLOB=y
arch/sh/configs/rsk7203_defconfig:CONFIG_SLOB=y
arch/sh/configs/se7206_defconfig:CONFIG_SLOB=y
arch/sh/configs/shmin_defconfig:CONFIG_SLOB=y
arch/sh/configs/shx3_defconfig:CONFIG_SLOB=y
kernel/configs/tiny.config:CONFIG_SLOB=y
$

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
