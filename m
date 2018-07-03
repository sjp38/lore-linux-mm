Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 604EE6B0273
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:35:31 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id d9-v6so1400244oth.18
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:35:31 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u185-v6si446973oib.207.2018.07.03.10.35.30
        for <linux-mm@kvack.org>;
        Tue, 03 Jul 2018 10:35:30 -0700 (PDT)
Date: Tue, 3 Jul 2018 18:36:08 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180703173608.GF27243@arm.com>
References: <cover.1530018818.git.andreyknvl@google.com>
 <20180628105057.GA26019@e103592.cambridge.arm.com>
 <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110709.GA17859@arm.com>
 <CAAeHK+wHd8B2nhat-Z2Y2=s4NVobPG7vjr2CynjFhqPTwQRepQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+wHd8B2nhat-Z2Y2=s4NVobPG7vjr2CynjFhqPTwQRepQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Dave Martin <Dave.Martin@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Fri, Jun 29, 2018 at 06:36:10PM +0200, Andrey Konovalov wrote:
> On Fri, Jun 29, 2018 at 1:07 PM, Will Deacon <will.deacon@arm.com> wrote:
> > It might not seen sensible, but we could still be relying on this in the
> > kernel and so this change would introduce a regression. I think we need
> > a way to identify such pointer usage before these patches can seriously be
> > considered for mainline inclusion.
> 
> Another point that I have here is that KHWASAN is a debugging tool not
> meant to be used in production. We're not trying to change the ABI or
> something like that (referring to the other HWASAN patchset). We can
> fix up the non obvious places where untagging is needed in a case by
> case basis with additional patches when testing reveals it.

Hmm, but elsewhere in this thread, Evgenii is motivating the need for this
patch set precisely because the lower overhead means it's suitable for
"near-production" use. So I don't think writing this off as a debugging
feature is the right approach, and we instead need to put effort into
analysing the impact of address tags on the kernel as a whole. Playing
whack-a-mole with subtle tag issues sounds like the worst possible outcome
for the long-term.

Will
