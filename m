Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 743B96B0008
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 13:10:05 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id k79so3393241ioi.6
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 10:10:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20sor1217079itb.129.2018.03.09.10.10.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 10:10:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180308112532.4ijhy4dyb6u72nvl@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com> <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
 <20180305144405.jhrftj56hnlfl4ko@lakrids.cambridge.arm.com>
 <CAAeHK+x0gjQT95Suq-xqpbSUVo4Z3r8j48vOOG+NCgGS+cnAGA@mail.gmail.com> <20180308112532.4ijhy4dyb6u72nvl@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 9 Mar 2018 19:10:03 +0100
Message-ID: <CAAeHK+w4DDWmzjhMx3Zv3QJDrzVfs5oYVZXdV0xs=58wkoecNw@mail.gmail.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Thu, Mar 8, 2018 at 12:25 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Tue, Mar 06, 2018 at 07:38:08PM +0100, Andrey Konovalov wrote:
>> On Mon, Mar 5, 2018 at 3:44 PM, Mark Rutland <mark.rutland@arm.com> wrote:
>> > On Fri, Mar 02, 2018 at 08:44:28PM +0100, Andrey Konovalov wrote:
>> >> +
>> >> +     for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
>> >> +             if (*shadow != tag) {
>> >> +                     /* Report invalid-access bug here */
>> >> +                     return;
>> >
>> > Huh? Should that be a TODO?
>>
>> This is fixed in one of the next commits. I decided to split the main
>> runtime logic and the reporting parts, so this comment is a
>> placeholder, which is replaced with the proper error reporting
>> function call later in the patch series. I can make it a /* TODO:
>> comment */, if you think that looks better.
>
> It might be preferable to introdcue the report functions first (i.e.
> swap this patch with the next one).
>
> Those will be unused, but since they're not static, you shouldn't get
> any build warnings. Then the hooks can call the report functions as soon
> as they're introduced.

Will do, thanks!
