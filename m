Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 715628E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:59:58 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id p131so8053736oig.10
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 07:59:58 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c25si6334103otp.232.2018.12.11.07.59.56
        for <linux-mm@kvack.org>;
        Tue, 11 Dec 2018 07:59:57 -0800 (PST)
Date: Tue, 11 Dec 2018 16:00:19 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v13 00/25] kasan: add software tag-based mode for arm64
Message-ID: <20181211160018.GA12597@edgewater-inn.cambridge.arm.com>
References: <cover.1544099024.git.andreyknvl@google.com>
 <20181211151829.GB11718@edgewater-inn.cambridge.arm.com>
 <CAAeHK+xxNsOfaUZhcErc+fjEEv0YZ-dbQ0fTXzQUO4dZbM-GgA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xxNsOfaUZhcErc+fjEEv0YZ-dbQ0fTXzQUO4dZbM-GgA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, akpm@linux-foundation.org
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgenii Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

[moving akpm to To:]

On Tue, Dec 11, 2018 at 04:57:27PM +0100, Andrey Konovalov wrote:
> On Tue, Dec 11, 2018 at 4:18 PM Will Deacon <will.deacon@arm.com> wrote:
> > On Thu, Dec 06, 2018 at 01:24:18PM +0100, Andrey Konovalov wrote:
> > > This patchset adds a new software tag-based mode to KASAN [1].
> > > (Initially this mode was called KHWASAN, but it got renamed,
> > >  see the naming rationale at the end of this section).
> > >
> > > The plan is to implement HWASan [2] for the kernel with the incentive,
> > > that it's going to have comparable to KASAN performance, but in the same
> > > time consume much less memory, trading that off for somewhat imprecise
> > > bug detection and being supported only for arm64.
> >
> > For the arm64 parts:
> >
> > Acked-by: Will Deacon <will.deacon@arm.com>
> >
> > I assume that you plan to replace the current patches in -mm with this
> > series?
> >
> > Cheers,
> >
> > Will
> 
> Hi Will,
> 
> Yes, that was the intention of sending v13. Should have I sent a
> separate patch with v12->v13 fixes instead? I don't know what's the
> usual way to make changes to the patchset once it's in the mm tree.

No, I was just checking that the intention was for akpm to pick this up in
preference to the old stuff! That works for me, and the minor conflict with
arm64 in next was already resolved by Stephen.

Will
