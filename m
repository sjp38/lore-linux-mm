Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4D3A6B051F
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 10:54:08 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id c17-v6so19732674ioi.15
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 07:54:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c7-v6sor450430iog.57.2018.11.07.07.54.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 07:54:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181107153456.GE2623@brain-police>
References: <cover.1541525354.git.andreyknvl@google.com> <CAAeHK+yOsP7V0gPu7EpqCbJZqbGQMZbAp6q1+=0dNGC24reyWg@mail.gmail.com>
 <20181107145922.GD2623@brain-police> <CAAeHK+zNgv9WxRpf7N3gmsLYGL6oUALAnyerMzeYZUz1LhoUuA@mail.gmail.com>
 <20181107153456.GE2623@brain-police>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 7 Nov 2018 16:54:05 +0100
Message-ID: <CAAeHK+zupkT2s8o3p7GmxLn2N7idJihBG=asuEBF6v6TheGo_A@mail.gmail.com>
Subject: Re: [PATCH v10 00/22] kasan: add software tag-based mode for arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>

On Wed, Nov 7, 2018 at 4:34 PM, Will Deacon <will.deacon@arm.com> wrote:
> On Wed, Nov 07, 2018 at 04:11:35PM +0100, Andrey Konovalov wrote:
>> On Wed, Nov 7, 2018 at 3:59 PM, Will Deacon <will.deacon@arm.com> wrote:
>> > On Wed, Nov 07, 2018 at 03:56:03PM +0100, Andrey Konovalov wrote:
>> >> On Tue, Nov 6, 2018 at 6:30 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> >> > This patchset adds a new software tag-based mode to KASAN [1].
>> >> > (Initially this mode was called KHWASAN, but it got renamed,
>> >> >  see the naming rationale at the end of this section).
>> >>
>> >> [...]
>> >>
>> >> > Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> >> > Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
>> >> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> >>
>> >> Hi Andrew,
>> >>
>> >> This patchset has now been reviewed-by KASAN maintainers. Could you
>> >> take a look and consider taking this into the -mm tree?
>> >
>> > I would much prefer to take the arm64 parts (which still need to be reviewed
>> > by Catalin afaict) via the arm64 tree, so please can you split those out
>> > separately?
>>
>> Which parts do you mean exactly, which patches? I don't think it makes
>> sense to split this patchset, as one part won't function without the
>> other.
>
> I would like the patches that touch code under arch/arm64/ to be reviewed by
> somebody from the arm64 community. Since the core parts have already been
> reviewed, I was suggesting that you could split them out so that they are
> not blocked by the architecture code. Is it not possible to preserve the
> existing KASAN behaviour for arm64 with the core parts merged? I figured it
> must be, since you're not touching any other architectures here and they
> assumedly continue to function correctly.
>
> However, if you'd rather keep everything together, please can we give it a
> couple of weeks so we can at least get the architecture bits reviewed? Most
> people are out at LPC next week (and I'm at another conference this week).
>
> Will
